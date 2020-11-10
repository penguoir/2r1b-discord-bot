class Role
  attr_accessor :owner
  attr_accessor :team
  attr_accessor :name


  def initialize(name, team, description)
    @name = name
    @team = team
    @description = description
    @owner = nil
  end

  def to_s
    %Q[```
Role: #{@name}
Description: #{@description} 
Team: #{@team}
```]
  end
end
