# frozen_string_literal: false

# Command - class representing a command executed on a user's server
class Command < Dry::Struct
  include Minion::Model

  TABLE = "commands"
  PROTECTED_ATTRIBUTES = [:id]

  attribute :id,        Types::String.optional
  attribute :server_id, Types::String
  attribute :user_id,   Types::String
  attribute :command,   Types::String
  attribute :stderr,    Types::Array do
    attribute :output,  Types::String.optional
    attribute :at,      Types::DateTime.optional
  end
  attribute :stdout,    Types::Array do
    attribute :output,  Types::String.optional
    attribute :at,      Types::DateTime.optional
  end
end


#
# For using in tests
#
c = Command.new({
  id: nil, server_id: 'abc123', user_id: 'asdfasdf', command:'ls /tmp',
  stdout: [
    { output: 'Permissions Size User Date Modified Name', at: Time.now.utc },
    { output: 'srwxrwxrwx     0 jah  23 May 22:11  .s.PGSQL.5432', at: Time.now.utc },
    { output: 'drwxr-xr-x     - jah  23 May  0:53  7AECB408-B6F3-4E22-ACD9-243D21358609', at: Time.now.utc }
  ],
  stderr: [
    { output: '"/somethingthatdoesntexist": No such file or directory (os error 2)', at: Time.now.utc }
  ]
})
