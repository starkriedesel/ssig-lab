# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

srand(0)
challenge_server = 'http://10.0.0.5'

ChallengeGroup.destroy_all
basic_group = ChallengeGroup.create({name: 'Basic', description: 'Basic Web Challenges'})
app_group = ChallengeGroup.create({name: 'Application', description: 'Application Challenges'})
other_group = ChallengeGroup.create({name: 'Other', description: 'Some extra challenges to pad the database'})

UserCompletedChallenge.destroy_all
ChallengeFlag.destroy_all
ChallengeHint.destroy_all

Challenge.destroy_all
Challenge.reset_pk_sequence
basic1_chall = Challenge.create({
  name: 'Basic 1',
  description: 'Break into this cool thingy',
  points: 10,
  challenge_group: basic_group,
  url: "#{challenge_server}/challenges/basic/1/index.php"
})
basic2_chall = Challenge.create({
  name: 'Basic 2',
  description: 'Break into this other cool thingy',
  points: 15,
  challenge_group: basic_group,
  url: "#{challenge_server}/challenges/basic/2/index.php"
})
basic3_chall = Challenge.create({
  name: 'Basic 3',
  description: 'So Hard!',
  points: 20,
  challenge_group: basic_group,
  url: "#{challenge_server}/challenges/basic/3/index.php"
})
app1_chall = Challenge.create({
  name: 'App 1',
  description: 'Tried my hand at some basic c++',
  points: 25,
  challenge_group: app_group,
  url: "#{challenge_server}/challenges/apps/1/index.php"
})
app2_chall = Challenge.create({
  name: 'App 2',
  description: 'Some C#',
  points: 15,
  challenge_group: app_group,
  url: "#{challenge_server}/challenges/apps/2/index.php"
})
other_challs = []
(1..10).each { |n|
  c = Challenge.new({
    name: "Other #{n}",
    description: "Other challenge ##{n}",
    points: (10 * (rand(5) + 1)),
    challenge_group: other_group,
    url: "#{challenge_server}/challenges/other/#{n}/",
  })
  c.save
  other_challs << c
}

Role.destroy_all
admin_role = Role.create({name: 'admin'})

User.destroy_all
User.reset_pk_sequence
admin_user = User.create({username: 'admin', email: 'admin@ssig-lab.com', password: 'admin123', password_confirmation: 'admin123', roles: [admin_role]})
moderator_user = User.create({username: 'moderator', email: 'moderator@ssig-lab.com', password: 'moderator123', password_confirmation: 'moderator123'})
test_user = User.create({username: 'user', email: 'user@ssig-lab.com', password: 'user123', password_confirmation: 'user123'})
test_user.completed_challenges << [basic1_chall, basic2_chall, app1_chall]
moderator_user.completed_challenges << [basic1_chall, app1_chall, app2_chall]
users = []
(1..10).each { |n|
  u = User.new({
    username: "user#{n}",
    email: "user#{n}@ssig-lab.com",
    password: "user#{n}#{n}#{n}",
    password_confirmation: "user#{n}#{n}#{n}"
  })
  u.save
  rand(4).times {
    c = other_challs[rand(other_challs.count)]
    u.completed_challenges << c unless u.completed_challenges.include? c
  }
  users << u
}
