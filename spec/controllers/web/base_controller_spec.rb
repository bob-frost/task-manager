require 'rails_helper'

RSpec.describe Web::BaseController, type: :controller do
  describe '#current_user' do
    let!(:user) { FactoryGirl.create :user }

    context 'when auth_token is not provided' do
      it 'returns nil' do
        expect(subject.current_user).to eq(nil)
      end
    end

    context 'when valid auth_token cookie is provided' do
      before do
        allow(cookies).to receive(:[]).with(:auth_token).and_return(user.auth_token)
      end

      it 'returns associated user' do
        expect(subject.current_user).to eq(user)
      end
    end

    context 'when invalid auth_token cookie is provided' do
      before do
        allow(cookies).to receive(:[]).with(:auth_token).and_return('invalid_auth_token')
      end

      it 'returns nil' do
        expect(subject.current_user).to eq(nil)
      end
    end
  end
end
