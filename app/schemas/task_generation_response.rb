require "ruby_llm/schema"

class TaskGenerationResponse < RubyLLM::Schema
  description "AIが送られてきたふりかえりに対して、タスクを5件生成する"

  array :tasks,
        of: :string,
        min_items: 5,
        max_items: 5,
        description: "5〜15分で実行できる小さいタスク。必ず5件。"
end
