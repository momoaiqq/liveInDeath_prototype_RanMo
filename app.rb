#!/usr/bin/env ruby

require 'sinatra'
require 'twilio-ruby'
require 'data_mapper'
require 'rubygems'
require_relative 'secret.rb'

# set :bind, "0.0.0.0"
#set up sinatra
configure do
  set :send_sms_password, "interact2013"
  conf=YAML.load_file('twilio_conf.yml')
  set :twilio_account_sid, conf['account_sid']
  set :twilio_auth_token, conf['auth_token']
  set :twilio_from_number, conf['from_number']

  mysql_conf=YAML.load_file('mysql_conf.yml')
  DataMapper.setup(:default, {
      :adapter => 'mysql',
      :host => mysql_conf['host'],
      :username => mysql_conf['username'] ,
      :password => mysql_conf['password'],
      :database => mysql_conf['database']})
  # Automatically create the tables if they don't exist
  DataMapper.auto_upgrade!
  # Finish setup
  DataMapper.finalize
end

helpers do
  def get_itpsss_facts
    facts = []
    facts << "Thank you for your rating! Hope you enjoy ITP secret!"
    facts << "Thank you for your rating! Sharing more great secret to unlock more high level secret!"
    facts << "Thank you for your rating! Sharing and reveiving, ITP Secret!"
#     facts << "Did you know that there are about 100 distinct breeds of domestic cat?  Plenty of furry love!"
#     facts << "Cats bury their feces to cover their trails from predators."
    facts[rand(facts.size)]
  end
  
  def remind_rating
    reminds = []
    reminds << "Please reply number 1-5 to rate the secret you've got to help us improve our service! Thank you!"
    reminds << "Like the secret you got there? Rate it and reply the number within the scope of 1-5. Thank you!"
    reminds << "Hope you enjoy ITP Secret! Please rate this secret by replying number 1-5. Thank you!"
    reminds[rand(reminds.size)]
  end  
  
  def sorry_words
  	words = []
	words << "Sorry, we couldn't match up the rating to a secret, that might because it's been more than 4 hours since you received last secret. "
    words << "Sorry, we couldn't match up the rating to a secret, that might because it's been more than 4 hours since you received last secret. "
    words[rand(words.size)]
  end
end

get "/" do
  #get the 20 most recent SECRET messages
  @sms_messages = Secret.all(:limit => 40, :order => [:created_at.desc])
  erb :main
end

#setting cookie
 enable :sessions

#receive SECRET and store in database
post "/receive_sms/?" do	
	puts "post receive_sms hope if!!"
  	body = params["Body"]  	 
	if body.length == 1 && body =~ /[12345]/	
		begin
		  if session["secretid"]
		    reply_message = get_itpsss_facts
			secret = Secret.get(session["secretid"].to_i)     # save the secret_id as integer   
			
			rating_from_sms = params['Body'].to_i     # save the rating(text) as integer
			rating = Rating.create(:score => rating_from_sms)
			secret.ratings << rating
			secret.save
			
			twiml = Twilio::TwiML::Response.new do |r|
			  r.Sms reply_message
			end
			twiml.text
		  
		  else
		    sorry_say = sorry_words
		    
		    twiml = Twilio::TwiML::Response.new do |r|
		      r.Sms sorry_say
		    end
		    twiml.text
		  end
			
		rescue
			# There's no session_id
			# Do something else			
			message = "Sorry, we couldn't match up the rating to a secret, that might because it's been more than 4 hours since you received last secret. "
     		
     		twiml = Twilio::TwiML::Response.new do |r|
     		 r.sms message
     		end
     		twiml.text
		end
		
# Get all the secrets' rating from rating table
  all_secret = []
  initial_rate = 0.0
  averages = 0.0
  for secret in Secret              # iterating each secret in secret table
    ratings = secret.ratings        
    rating_values=[]
    average_values=[]

    
    ratings.each do |rating|
    rating_values << rating.score.to_i  # transform the strings in rating_values into integer and save them 
    end
    
    # iterating each rating_value, sum values up and divide by length  
    rating_values.each do |rating_value|   
      if rating_values.length >= 0
        # puts "HERE COMES #{rating_values.length}"   
        sum = 0.0
        for v in rating_values
          sum = sum + v
        end
        avg = sum / rating_values.length

        # initial_rate += rating_value
        # averages = initial_rate / rating_values.length
         
        # delete_old = Average.get(average.length - 1)
        # delete_old.destroy
     # puts "This is the average_rating #{average[2]} + average_rating #{average[1]}"
        initial_rate = 0.0


      else
        puts "I don't have any rating to show"
      end
        average = Average.first_or_create(:average_ratings => avg)
        # puts "This is the averages #{average_values}"
        secret.averages << average
    #puts secret.inspect
        secret.save
    end
    

    # set_values = 0.0
    #   for a_values in average_values 
    #     set_values += average_values.last
    #   end
      # puts "HERE COMES #{average_values}"



  end   
    
		# saving level info based on average rating			
    	# initial_average = 0.0           # calculate level from average ratings
    	# levels = 0.0
    	# for caller in Caller              # iterating each secret in secret table
    	#   averages = caller.averages        
    	#   average_values=[]
    	  
    	#   averages.each do |average|
    	# 	  average_values << average.average_ratings
    	#   end
    	# # iterating each average_rating_value, sum values up and divide by length
    	#   average_values.each do |average_value|
    	# 	  initial_average += average_value
    	# 	  levels = initial_average / average_values.length
    	# 	  puts "This is the level #{levels}"
    	#   end
      
    	#   level = Level.first_or_create(:level => levels)
    	#   caller.levels  << level
    	#   caller.save
    	  
    	#   initial_average = 0.0  
    	# end

         
  else # it must be a secret!
  	return_secret = Secret.first(:offset => rand(Secret.count))
  	puts return_secret.inspect
  	session["secretid"] = return_secret.id
  	secret_id = session["secretid"]
  	puts secret_id.inspect
  
  	#save this secret
    secret = Secret.create(:body => params['Body'], :created_at => Time.now)
    caller = Caller.first_or_create(:from => params['From'])
    caller.secrets << secret
    caller.save
    
  
  #return a random saved secret
    #return_secret = Secret.first(:offset => rand(Secret.count))
  	twiml = Twilio::TwiML::Response.new do |r|
  		r.Sms return_secret.body
  #send another message to remind user for 
  
	    ask_rating = remind_rating
	    r.Sms ask_rating
	end
	session["secretid"]
	twiml.text
    end
end

# get "/" do
# 	"Your secret id is #{return_secret[:id]}"
# end

get "/send_sms/?" do
   erb :send_sms_form
end