# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should be_valid }

  describe "when name is not present" do
	before { @user.name = " " }
	it { should_not be_valid }
  end

  describe "when email is not present" do
	before { @user.email = " " }
	it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

 describe "with a password that's too short" do
  before { @user.password = @user.password_confirmation = "a" * 5 }
  it { should be_invalid }
end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "when name is too long" do
	before { @user.name = "a" * 51 }
	it { should_not be_valid }
  end

  describe "when email address is already taken" do
	before do
	  user_with_same_email = @user.dup
	  user_with_same_email.email = @user.email.upcase
	  user_with_same_email.save
	end
	it { should_not be_valid }
  end

	describe "when email format is invalid" do
	it "should be invalid" do
	  addresses = %w[user@foo,com user_at_foo.org example.user@foo.
					 foo@bar_baz.com foo@bar+baz.com]
	  addresses.each do |invalid_address|
		@user.email = invalid_address
		@user.should_not be_valid
	  end      
	end
  end

  describe "when email format is valid" do
	it "should be valid" do
	  addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
	  addresses.each do |valid_address|
		@user.email = valid_address
		@user.should be_valid
	  end      
	end
  end
  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
     it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
  end
end