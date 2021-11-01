# Exercise 6
require "test/unit"

class LaunchDiscussionWorkflow

  attr_reader :participants, :successful

  def initialize(discussion, host, participants_email_string)
    @discussion = discussion
    @host = host
    @participants_email_string = participants_email_string
    @participants = []
  end

  def launch_discussion 
    return unless valid? 
    # would the system prefer return nothing if invalid? or an error? or something else?
    run_callbacks(:create) do
      ActiveRecord::Base.transaction do
        discussion.save!
        create_discussion_roles!
        @successful = true
      end
    end
  end

  def generate_participant_users_from_email_string
    return if @participants_email_string.blank?
    @participants_email_string.split.uniq.map do |email_address|
      User.create(email: email_address.downcase, password: Devise.friendly_token)
    end
  end

end

class TestLaunchDiscussionWorkflow < Test::Unit::TestCase 

  def test_setup
    @discussion = Discussion.new(title: "fake", ...)
    @host = User.find(42)
    @participants = "fake1@example.com\nfake2@example.com\nfake3@example.com"
    @workflow = LaunchDiscussionWorkflow.new(discussion, host, participants)
    @workflow.generate_participant_users_from_email_string
  end

  def test_generate_participant_users_from_email_string 
    @workflow.participants do |participant|
      return false unless participant.is_a?(User) 
    end
    return true 
  end

  def test_launch_discussion
    assert_equal(true, @workflow.launch_discussion.successful)
  end

  def run_tests 
    test_setup
    puts test_launch_discussion
    puts test_generate_participant_users_from_email_string
  end

end


# moved tests into test class
TestLaunchDiscussionWorkflow.run_tests
