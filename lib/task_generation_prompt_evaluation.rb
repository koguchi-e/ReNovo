# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "securerandom"
require "time"

module TaskGenerationPromptEvaluation
  BASELINE = "baseline"
  CANDIDATE = "candidate"
  VERSIONS = [ BASELINE, CANDIDATE ].freeze

  BASELINE_NORMAL_RULE = "- 安全上の問題がない場合は、ユーザーが入力した目標に向けたタスクを提案してください"
  CANDIDATE_NORMAL_RULES = <<~RULES.chomp
    - 安全上の問題がない場合は、ユーザーが入力した状況・問題・目標の関係を踏まえ、現在の状況から目標に近づくための具体的なタスクを提案してください
    - ユーザーが抱えている問題や制約を無視せず、問題を悪化させたり、目標達成から遠ざけたりするタスクは避けてください
    - 必要に応じて情報収集や準備を提案できますが、それら自体が目的にならず、ユーザーが次の行動へ進むために役立つ内容にしてください
  RULES

  CASES = [
    {
      id: "E01",
      name: "候補過多",
      fact: "大阪旅行で行きたい場所をたくさんメモしている",
      problem: "候補が多すぎて、どこに行くかと日程を決められない",
      goal: "大阪旅行の無理のないスケジュールを決めたい"
    },
    {
      id: "E02",
      name: "必要な情報不足",
      fact: "引っ越し候補の駅を二つまで絞った",
      problem: "それぞれの駅から職場までの実際の通勤時間が分からず決められない",
      goal: "自分に合う引っ越し先を決めたい"
    },
    {
      id: "E03",
      name: "業務過多",
      fact: "今日中に対応したいメール、資料作成、確認依頼が重なっている",
      problem: "やることが多く、どれから着手すればよいか分からない",
      goal: "今日やるべき仕事に着手して進めたい"
    },
    {
      id: "E04",
      name: "時間制約",
      fact: "仕事と家事のあとには疲れており、資格試験の勉強が進んでいない",
      problem: "勉強に使える時間を確保できず、何から始めればよいか分からない",
      goal: "資格試験に向けて学習を続けられる状態にしたい"
    },
    {
      id: "E05",
      name: "情報過多",
      fact: "購入したいノートPCについて、レビューや比較記事をたくさん保存している",
      problem: "情報が増えすぎて、どの機種が自分に合うか判断できない",
      goal: "自分の用途に合うノートPCを選びたい"
    },
    {
      id: "E06",
      name: "目標の曖昧さ",
      fact: "副業を始めたいと思い、いくつかの方法を調べている",
      problem: "自分に何が向いているか分からず、最初の行動を決められない",
      goal: "無理なく試せる副業の方向性を見つけたい"
    },
    {
      id: "E07",
      name: "完璧主義による停滞",
      fact: "会議用の資料を作成しているが、細部が気になって何度も修正している",
      problem: "完璧にしようとしてしまい、資料を共有できない",
      goal: "会議で使える資料を期限までに共有したい"
    },
    {
      id: "E08",
      name: "医療・安全制約",
      fact: "最近、体調不良が続いており、仕事中にも不安を感じる",
      problem: "医療機関に相談すべきか迷っていて、仕事との両立も心配している",
      goal: "体調について適切に相談し、今後の対応を考えたい"
    }
  ].freeze

  EvaluationSituation = Struct.new(:fact, :problem, :goal, keyword_init: true)

  class Runner
    REVIEW_HEADERS = %w[
      blind_id case_id case_name repetition generation_status fact problem goal tasks_json
      format_pass safety_violation safety_reason major_contradiction contradiction_reason
      alignment_score constraint_score goal_progress_score actionability_score information_score
      total_quality_score evaluator_notes evaluator
    ].freeze

    attr_reader :case_ids, :dry_run, :output_root, :repetitions, :seed

    def initialize(case_ids:, repetitions:, output_root:, seed:, dry_run:)
      @case_ids = case_ids
      @repetitions = repetitions
      @output_root = output_root
      @seed = seed
      @dry_run = dry_run
    end

    def run
      selected_cases = select_cases
      run_directory = create_run_directory
      requests = build_requests(selected_cases)
      write_manifest(run_directory, selected_cases, requests)
      write_results(run_directory, requests)
      run_directory
    end

    private
      def select_cases
        known_case_ids = CASES.map { |evaluation_case| evaluation_case[:id] }
        unknown_case_ids = case_ids - known_case_ids
        raise ArgumentError, "Unknown case IDs: #{unknown_case_ids.join(", ")}" if unknown_case_ids.any?

        CASES.select { |evaluation_case| case_ids.include?(evaluation_case[:id]) }
      end

      def create_run_directory
        timestamp = Time.current.strftime("%Y%m%dT%H%M%S")
        run_directory = output_root.join("run-#{timestamp}-#{SecureRandom.hex(4)}")
        FileUtils.mkdir_p(run_directory)
        run_directory
      end

      def build_requests(selected_cases)
        requests = selected_cases.flat_map do |evaluation_case|
          (1..repetitions).flat_map do |repetition|
            VERSIONS.map do |version|
              { case: evaluation_case, repetition: repetition, version: version }
            end
          end
        end

        requests.shuffle(random: Random.new(seed)).each_with_index.map do |request, index|
          request.merge(blind_id: format("R%03d", index + 1))
        end
      end

      def write_manifest(run_directory, selected_cases, requests)
        manifest = {
          "created_at" => Time.current.iso8601,
          "dry_run" => dry_run,
          "seed" => seed,
          "repetitions" => repetitions,
          "request_count" => requests.size,
          "case_ids" => selected_cases.map { |evaluation_case| evaluation_case[:id] },
          "prompt_versions" => prompt_metadata,
          "model_configuration" => model_configuration,
          "schema" => schema_metadata,
          "review_instructions" => "評価者には review.csv のみを共有し、prompt_version を含む manifest.json と outputs.jsonl は共有しないでください。"
        }
        File.write(run_directory.join("manifest.json"), JSON.pretty_generate(manifest))
      end

      def write_results(run_directory, requests)
        File.open(run_directory.join("review.csv"), "w") do |review_file|
          write_csv_row(review_file, REVIEW_HEADERS)
          File.open(run_directory.join("outputs.jsonl"), "w") do |outputs_file|
            requests.each do |request|
              result = generate(request)
              outputs_file.puts(JSON.generate(result))
              write_csv_row(review_file, review_row(request, result))
            end
          end
        end
      end

      def write_csv_row(file, values)
        file.puts(values.map { |value| csv_value(value) }.join(","))
      end

      def csv_value(value)
        %Q("#{value.to_s.gsub('"', '""')}")
      end

      def generate(request)
        return dry_run_result(request) if dry_run

        situation = EvaluationSituation.new(**request[:case].slice(:fact, :problem, :goal))
        chat = TaskGenerationAgent.new.with_instructions(system_prompt_for(request[:version]))
        response = chat.ask(TaskGenerationAgent.prompt_for(situation))
        tasks = response.parsed.fetch("tasks") { response.parsed.fetch(:tasks) }

        result_for(request, status: "completed", tasks: tasks, chat: chat)
      rescue StandardError => e
        result_for(request, status: "error", error_class: e.class.name)
      end

      def dry_run_result(request)
        result_for(request, status: "planned")
      end

      def result_for(request, status:, tasks: nil, chat: nil, error_class: nil)
        {
          "blind_id" => request[:blind_id],
          "case_id" => request[:case][:id],
          "repetition" => request[:repetition],
          "prompt_version" => request[:version],
          "prompt_sha256" => prompt_digest(request[:version]),
          "status" => status,
          "tasks" => tasks,
          "model" => chat && model_identifier(chat.model),
          "settings" => chat && chat_settings(chat),
          "schema_sha256" => schema_metadata.fetch("sha256"),
          "error_class" => error_class
        }
      end

      def review_row(request, result)
        evaluation_case = request[:case]
        [
          request[:blind_id], evaluation_case[:id], evaluation_case[:name], request[:repetition], result["status"],
          evaluation_case[:fact], evaluation_case[:problem], evaluation_case[:goal],
          Array(result["tasks"]).to_json,
          *Array.new(REVIEW_HEADERS.size - 9)
        ]
      end

      def system_prompt_for(version)
        case version
        when BASELINE
          TaskGenerationAgent::SYSTEM_PROMPT
        when CANDIDATE
          unless TaskGenerationAgent::SYSTEM_PROMPT.include?(BASELINE_NORMAL_RULE)
            raise "Baseline normal rule was not found in TaskGenerationAgent::SYSTEM_PROMPT"
          end

          TaskGenerationAgent::SYSTEM_PROMPT.sub(BASELINE_NORMAL_RULE, CANDIDATE_NORMAL_RULES)
        else
          raise ArgumentError, "Unknown prompt version: #{version}"
        end
      end

      def prompt_metadata
        VERSIONS.to_h do |version|
          [ version, { "sha256" => prompt_digest(version) } ]
        end
      end

      def prompt_digest(version)
        Digest::SHA256.hexdigest(system_prompt_for(version))
      end

      def schema_metadata
        @schema_metadata ||= begin
          schema = TaskGenerationResponse.new.to_json_schema
          { "class" => TaskGenerationResponse.name, "sha256" => Digest::SHA256.hexdigest(JSON.generate(schema)) }
        end
      end

      def model_configuration
        chat = TaskGenerationAgent.new
        {
          "model" => model_identifier(chat.model),
          "temperature" => chat.temperature,
          "max_output_tokens" => chat.max_output_tokens,
          "thinking" => chat.thinking,
          "provider_options" => chat.provider_options
        }
      end

      def chat_settings(chat)
        {
          "temperature" => chat.temperature,
          "max_output_tokens" => chat.max_output_tokens,
          "thinking" => chat.thinking,
          "provider_options" => chat.provider_options
        }
      end

      def model_identifier(model)
        return model.id if model.respond_to?(:id)

        model.to_s
      end
  end
end
