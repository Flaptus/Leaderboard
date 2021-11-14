require "json"
require "mongo"
require 'bcrypt'
require "sinatra"
require "open-uri"
require "net/http"

set :bind, "0.0.0.0"
FlaptusDB = Mongo::Client.new(ENV["mongouri"], database: "flaptus")[:leaderboard]


get "/" do
	"W.I.P."
end

get "/api/leaderboard" do
	FlaptusDB.find({}, sort: { score: -1 }).map do |col|
		{
			score:   col[:score],
			username: col[:username]
		}
	end.to_json
end

post "/api/newuser" do
	return halt 403, "Invalid secret provided" if params[:secret] != ENV["SECRET"]

	username = params[:username]

	return halt 400, "Username length > 12" if username.length > 12
	return halt 400, "Username not available" if FlaptusDB.find({ username_low: username.downcase }).first != nil

	token = BCrypt::Password.create(username + ENV["SECRET"]).to_s

	FlaptusDB.insert_one({
		score:        0,
		token:        token,
		username:     username,
		username_low: username.downcase
	})

	token
end


post "/api/newscore" do
	time = Time.now
	return halt 403, "Invalid secret provided" if params[:secret] != ENV["SECRET"]

	score = params[:score].to_i
	token = params[:token]

	user = FlaptusDB.find({ token: token }).first
	return 400 if user == nil

	return 200 if score <= user[:score]

	FlaptusDB.update_one({ token: token }, { "$set" => { score: score } })
	200
end
