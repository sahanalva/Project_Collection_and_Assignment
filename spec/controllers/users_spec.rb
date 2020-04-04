require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'responds successfully with an HTTP 200 status code' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'find user with given search attribute' do
    before :each do
      @user1 = create(:user)
      @user2 = create(:user, firstname: "Bob", lastname:"Builder", email: "bob@example.com", uin: "1234567")
    end
    
  end

end
