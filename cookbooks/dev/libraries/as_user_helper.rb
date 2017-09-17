
module AsUser
  def as_user(user, cmd)
    "su #{user} -l -c '#{cmd}'"
  end
end


