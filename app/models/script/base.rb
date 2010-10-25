class Script::Base < ActiveRecord::Base

  set_table_name "scripts"

  include Script::Support::ActiveRecord
  include Script::Support::Execution
  include Script::Support::Parameter

  def inspect
    t = (execution_time || game_time) - game_time
    time = " [#{t.round >= 0 ? "+" : "-"}#{((t * -1) / 60.0).floor}:#{"%02d" % (t.floor % 60)}]" if execution_time
    "#{self.class.internal_name}#{time}"
  end

end
