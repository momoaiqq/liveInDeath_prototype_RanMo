require 'data_mapper'

#Data model for received SMS

  class Caller #table of caller id
    include DataMapper::Resource
    property :id,          Serial
    property :from,        String
    #property :level,       Integer
    
  #validates_uniqueness_of :from
    has n, :secrets    # a caller has one or more secrets
#     has n, :ratings, :through => :secrets
#   has n, :levels 
  end
# 
  class Secret  #secrets belong to caller id
    include DataMapper::Resource
    property :id,          Serial
    property :body,        Text
    property :created_at,  DateTime
#     property :average_ratings, Float
# 
    belongs_to :caller # a secret belongs to a caller id
    has n, :averages
    has n, :ratings  #each secret has one or more ratings
  end
# 

  class Average # secrets belong to average
    include DataMapper::Resource
    property :id,          Serial
    property :average_ratings, Float
    
    belongs_to :secret
  end
  
#   class Level
#     include DataMapper::Resource
#     property :id,           Serial
#     property :level,        Float
#     
#     belongs_to :caller
#   end

  class Rating
    include DataMapper::Resource
    property :id,           Serial
    property :score,         Text
    belongs_to :secret   # a rating belongs to a secret 
  end

#   class Caller #table of caller id
#     include DataMapper::Resource
#     property :id,          Serial
#     property :from,        String
#     #property :level,       Integer
#     
# 	#validates_uniqueness_of :from
#     has n, :secrets    # a caller has one or more secrets
#     has n, :ratings, :through => :secrets
#     has n, :averages
# 	has n, :levels
#   end
# # 
#   class Secret  #secrets belong to caller id
#     include DataMapper::Resource
#     property :id,          Serial
#     property :body,        Text
#     property :created_at,  DateTime
# #     property :average_ratings, Float
# # 
#     belongs_to :caller # a secret belongs to a caller id
#     has n, :averages
#     has n, :ratings  #each secret has one or more ratings
#   end
# # 
# 
#   class Average # secrets belong to average
#     include DataMapper::Resource
#     property :id,          Serial
#     property :average_ratings, Float
#     
#     belongs_to :secret
#     belongs_to :caller
#   end
#   
#   class Level
#     include DataMapper::Resource
#     property :id,           Serial
#     property :level,        Float
#     
# #     has n, :level
#     belongs_to :caller
#   end
# 
#   class Rating
#     include DataMapper::Resource
#     property :id,           Serial
#     property :score,         Text
#     belongs_to :secret   # a rating belongs to a secret 
#   end
