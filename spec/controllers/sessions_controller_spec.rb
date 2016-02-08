require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET new' do
    context 'when user is logged out' do
      it 'returns 200 response' do
        get :new
        expect(response.status).to eq(200)
      end
    end

    context 'when user is logged in' do
      before do
        login
      end

      it 'redirects to home page' do
        get :new
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'POST create' do
    context 'with valid credentials' do
      let(:valid_credentials) { { email: FactoryGirl.generate(:email), password: '12345' } }
      let!(:user) { FactoryGirl.create(:user, email: valid_credentials[:email], password: valid_credentials[:password], password_confirmation: valid_credentials[:password]) }
      
      it 'sets auth_token cookie' do
        expect(cookies).to receive(:[]=).with(:auth_token, user.auth_token)
        post :create, valid_credentials
      end

      it 'sets permanent auth_token cookie if "remember" param equals "1"' do
        params = valid_credentials.merge(remember: '1')
        expect(cookies.permanent).to receive(:[]=).with(:auth_token, user.auth_token)
        post :create, params
      end

      it 'redirects to user page' do
        post :create, valid_credentials
        expect(response).to redirect_to(user)
      end

      context 'when responding to JSON' do
        it 'returns auth_token' do
          post :create, valid_credentials.merge(format: :json)
          expect(response.body).to eq({auth_token: user.auth_token}.to_json)
        end
      end

      context 'when user is logged in' do
        let(:another_user) { FactoryGirl.build_stubbed(:user) }

        before do
          login_as another_user
        end

        it 'does not change auth_token cookie' do
          expect(cookies).to_not receive(:[]=)
          post :create, valid_credentials
        end

        it 'redirects to home page' do
          post :create, valid_credentials
          expect(response).to redirect_to(root_url)
        end
      end
    end

    context 'with invalid email and password' do
      let(:invalid_credentials) { { email: 'not_exist@example.com', password: 'invalid' } }

      it 'does not set auth_token cookie' do
        expect(cookies).to_not receive(:[]=)
        post :create, invalid_credentials
      end

      it 'renders "new" page' do
        post :create, invalid_credentials
        expect(response).to render_template('new')
      end

      context 'when responding to JSON' do
        it 'returns 401 response' do
          post :create, invalid_credentials.merge(format: :json)
          expect(response.status).to eq(401)
        end

        it 'returns error message' do
          post :create, invalid_credentials.merge(format: :json)
          expect(response.body).to eq({ error: 'Invalid email and/or password' }.to_json)
        end
      end
    end

    context 'with invalid password' do
      let!(:user) { FactoryGirl.create :user }
      let(:invalid_credentials) { { email: user.email, password: 'invalid' } }

      it 'does not set auth_token cookie' do
        expect(cookies).to_not receive(:[]=)
        post :create, invalid_credentials
      end

      it 'renders "new" page' do
        post :create, invalid_credentials
        expect(response).to render_template('new')
      end

      context 'when responding to JSON' do
        it 'returns 401 response' do
          post :create, invalid_credentials.merge(format: :json)
          expect(response.status).to eq(401)
        end

        it 'returns error message' do
          post :create, invalid_credentials.merge(format: :json)
          expect(response.body).to eq({ error: 'Invalid email and/or password' }.to_json)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    it 'deletes auth_token cookie' do
      expect(cookies).to receive(:delete).with(:auth_token)
      delete :destroy
    end

    it 'redirects to home page' do
      delete :destroy
      expect(response).to redirect_to(root_url)
    end
  end
end
