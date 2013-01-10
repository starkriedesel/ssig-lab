# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

challenge_server = 'https://ssig-lab.dyndns-ip.com:81'

ChallengeGroup.destroy_all
basic_group = ChallengeGroup.create({name: 'Basic', description: 'Basic Web Challenges'}, :without_protection => true)
app_group = ChallengeGroup.create({name: 'Application', description: 'Application Challenges'}, :without_protection => true)

Challenge.destroy_all
Challenge.reset_pk_sequence
basic1_chall = Challenge.create({name: 'Basic 1', description: 'Break into this cool thingy', hint: 'Source code often hides secrets', points: 10, challenge_group: basic_group, url: challenge_server+'/challenges/basic/1/index.php'}, :without_protection => true)
basic2_chall = Challenge.create({name: 'Basic 2', description: 'Break into this other cool thingy', hint: 'Javascript is client side', points: 15, challenge_group: basic_group, url: challenge_server+'/challenges/basic/2/index.php'}, :without_protection => true)
basic3_chall = Challenge.create({name: 'Basic 3', description: 'So Hard!', hint: 'Check the headers', points: 20, challenge_group: basic_group, url: challenge_server+'/challenges/basic/3/index.php'}, :without_protection => true)
app1_chall = Challenge.create({name: 'App 1', description: 'Tried my hand at some basic c++', hint: "Check the methods being used for comparisons", points: 25, challenge_group: app_group, url: challenge_server+'/challenges/apps/1/index.php'}, :without_protection => true)
app2_chall = Challenge.create({name: 'App 2', description: 'Some C#', hint: 'C# tends to keep more info in the executable than is safe', points: 15, challenge_group: app_group, url: challenge_server+'/challenges/apps/2/index.php'}, :without_protection => true)

UserCompletedChallenge.destroy_all
ChallengeFlag.destroy_all

Role.destroy_all
admin_role = Role.create({name: 'admin'}, :without_protection => true)

User.destroy_all
User.reset_pk_sequence
admin_user = User.create({username: 'admin', email: 'admin@ssig-lab.dyndns-ip.com', password: 'admin123', password_confirmation: 'admin123', roles: [admin_role]}, :without_protection => true)
moderator_user = User.create({username: 'moderator', email: 'moderator@ssig-lab.dyndns-ip.com', password: 'moderator123', password_confirmation: 'moderator123', roles: [], completed_challenges: [basic1_chall, basic2_chall, basic3_chall, app1_chall, app2_chall]}, :without_protection => true)
test_user = User.create({username: 'user', email: 'user@ssig-lab.dyndns-ip.com', password: 'user123', password_confirmation: 'user123', roles: [], completed_challenges: [basic1_chall, basic2_chall]}, :without_protection => true)
