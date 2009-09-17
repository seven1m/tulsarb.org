#!/usr/bin/env ruby

# tulsa.rb

require 'place_to_meet'
require 'rubyists'

class RubyUserGroup < UserGroup

  has_many_interests :ruby, :rails, :sinatra, :jruby, :ruby19, :etc

  def find_place_to_meet(within) # :collapse:
    PlaceToMeet.find_all_within_radius(within).detect do |place|
      place.available? and \
      place.has_free_wifi?
    end
  end

  def have_meeting # :collapse:
    organizer = organizers.detect { |o| not o.busy? }
    place = find_place_to_meet(10.miles)
    if organizer and place
      organizer.notify_rubyists_via(:twitter, :website, :calendar, :google_group)
      Meeting.new(:place => place)
    end
  end

end

if $0 == __FILE__

  tulsa_ruby_user_group = RubyUserGroup.new(
    :website      => 'http://tulsarb.org',
    :twitter      => 'http://twitter.com/tulsarb',
    :calendar     => 'http://tinyurl.com/tulsarbcal',
    :google_group => 'http://groups.google.com/group/tulsarb',
    :organizers   => [
      Rubyist.find_by_url('http://timmorgan.org'),
      Rubyist.find_by_url('http://ibspoof.com')
    ]
  )

  loop do
    tulsa_ruby_user_group.have_meeting
    sleep 1.month
  end
  
end

# email info@tulsarb.org or ask questions in our Google Group (url above)
# website inspired by http://jobs.37signals.com/jobs/5572
# fork this at http://github.com/seven1m/tulsarb.org

