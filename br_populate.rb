require 'net/http'
require 'net/https' # for ruby 1.8.7
require 'json'

module BRPopulate
  def self.states
    http = Net::HTTP.new('raw.githubusercontent.com', 443); http.use_ssl = true
    JSON.parse http.get('/hjemmel/br_populate/master/states.json').body
  end

  def self.capital?(city, state)
    city['name'] == state["capital"]
  end

  def self.populate
    ActiveRecord::Base.transaction do
      states.each do |state|
        state_obj = State.find_or_create_by(acronym: state["acronym"], name: state["name"], code: state['code'])

        state["cities"].each { |city| City.find_or_create_by(name: city['name'], state: state_obj, code: city['code'], capital: capital?(city, state)) }
      end
    end
  end
end
