require 'dotenv'
Dotenv.load

require './lib/role'
require 'discordrb'
require 'byebug'
require 'concurrent'

class Discordrb::User
  attr_accessor :role
end

##
# Constants

TOKEN = ENV['DISCORD_TOKEN']
ROLES = [
  Role.new('President', 'blue', 'Stay away from the bomber'),
  Role.new('Bomber', 'red', 'Be in the same room as the president'),
  Role.new('Spy', 'blue', 'You are not on the blue team. You are on the red team. You can decieve other players by using /show to show your fake team'),
  Role.new('Spy', 'red', 'You are not on the red team. You are on the blue team. You can decieve other players by using /show to show your fake team')
]

##
# Init the bot

bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  prefix: '/'
)


##
# Variables which change throughout play

joined_users = []
is_game_started = false
remaining_roles = ROLES


##
# Returns a user of @mention in args

def user_from_args(args, bot)
  user_req = Discordrb::API::User.resolve("Bot #{TOKEN}", args.first[2...-1])
  Discordrb::User.new(JSON.parse(user_req.body), bot)
end


bot.command :byebug do |event|
  byebug
end


##
# Check the status of the game

bot.command :status do |event|
  %Q(
```
joined_users: #{joined_users.map { |u| u.name }.join(', ')}
is_game_started: #{is_game_started}
```
  )
end


##
# Add yourself to the game

bot.command :join do |event|
  return ":x: can't join the game, it's already running" if is_game_started

  user = event.user
  return ":x: you're already in the game" if joined_users.include? user

  joined_users.push(user)

  ":dancer: #{user.name} has joined the 2r1b game."
end


##
# Remove yourself from the game

bot.command :leave do |event, *args|
  return ":x: can't leave, game has started" if is_game_started
  user = event.user
  joined_users.delete(user)

  ":leaves: #{user.name} has left the 2r1b game."
end

##
# Remove all players

bot.command :clear do |event|
  return "can't clear, game has started" if is_game_started
  joined_users.clear
end

##
# Stop the game

bot.command :stop do |event|
  return ":x: no running game" unless is_game_started

  is_game_started = false
  remaining_roles = ROLES

  ":stop_sign: stopped the game"
end


##
# Show another user your card

bot.command :show_full do |event, *args|
  user_from_args(args, bot).pm(
    "**#{event.user.name} has shown you their card**: #{event.user.role.to_s}"
  )
end

bot.command :show_team do |event, *args|
  user_from_args(args, bot).pm(
    "**#{event.user.name} has shown you their team**: #{event.user.role.team}"
  )
end

##
# At the end of the game, show everyone's cards

bot.command :end_of_game do |event, *args|
  joined_users.each do |u|
    event << "**#{u.name}** - [#{u.role.team}] #{u.role.name}"
  end

  nil
end

def start_timer(duration, channel)
  Thread.new {
    sleep duration
    channel.send_message("--- **Timer for #{duration/60} minutes is over!!** ---")
  }
end

timer = nil

##
# Start a timer of (arg) minutes

bot.command :timer do |event, *args|
  return ":x: no duration specified" unless args.first
  duration = args.first.to_f

  timer = start_timer(duration * 60, event.channel)

  "starting a timer for #{duration} minutes"
end

bot.command :stop_timer do |event|
  return "no timer set." if timer.nil?

  if timer.kill
    "stopped the timer"
  else
    "couldn't stop the timer??? what's going on???"
  end
end


##
# Start the game

bot.command :start do |event|
  return ":x: game is already started, `/stop` to stop" if is_game_started
  # return ":x: not enough players to start" if joined_users.size < 4

  remaining_roles = ROLES
  is_game_started = true

  joined_users.each do |u|
    # Get a random role
    role = remaining_roles.sample

    # Set the user's role
    u.role = role

    # Delete from possible roles array
    remaining_roles.delete(role)

    # Let the user know about it
    u.pm(role.to_s)
  end

  # Split into teams
  half = joined_users.size/2.to_f

  room_a = joined_users.sample(half.ceil)
  room_b = joined_users - room_a

  ":rocket: Started the game! I've DM\'d #{joined_users.size} players their"\
  " roles. Use `/show @user#1234` and `/swap @user#1234` to show or swap"\
  " cards with a user. \n\n"\
  " **Room A**: #{room_a.map { |u| u.name }.join(', ')}\n"\
  " **Room B**: #{room_b.map { |u| u.name }.join(', ')}"
end


##
# Start the bot

bot.run
