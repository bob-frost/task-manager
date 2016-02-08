require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET show' do
    context 'when user exists' do
      let(:user) { FactoryGirl.create :user }

      it 'returns 200 response' do
        get :show, id: user.id
        expect(response.status).to eq(200)
      end

      it 'provides requested user to the view' do
        get :show, id: user.id
        expect(controller.view_context.resource_user).to eq(user)
      end
    end

    context 'when user does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          get :show, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET new' do
    context 'when user is logged out' do
      it 'returns 200 response' do
        get :new
        expect(response.status).to eq(200)
      end

      it 'provides new user to the view' do
        get :new
        expect(controller.view_context.resource_user).to be_a_new(User)
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
    context 'when user is logged out' do
      context 'with valid params' do
        let(:valid_params) { FactoryGirl.attributes_for :user }

        it 'creates new user' do
          expect do
            post :create, user: valid_params
          end.to change(User, :count).by 1
        end

        it 'assigns correct attributes' do
          post :create, user: valid_params
          user = User.last
          expect(user.email).to eq(valid_params[:email])
          expect(user.login).to eq(valid_params[:login])
          expect(user.authenticate(valid_params[:password])).to eq(user)
        end

        it 'does not allow to set role' do
          params = valid_params.merge(role_id: Role.first.id)
          post :create, user: params
          expect(User.last.role).to eq(nil)
        end

        it 'log in created user' do
          post :create, user: valid_params
          expect(controller.current_user).to eq(User.last)
        end

        it 'redirects to created user' do
          post :create, user: valid_params
          expect(response).to redirect_to(User.last)
        end

        context 'when responding to JSON' do
          it 'returns 201 response' do
            post :create, user: valid_params, format: :json
            expect(response.status).to eq(201)
          end

          it 'renders "show" template' do
            post :create, user: valid_params, format: :json
            expect(response).to render_template('show')
          end

          it 'provides requested user to the view' do
            post :create, user: valid_params, format: :json
            expect(controller.view_context.resource_user).to eq(User.last)
          end
        end
      end

      context 'with invalid params' do
        let(:invalid_params) { FactoryGirl.attributes_for(:user).merge(email: 'invalid') }

        it 'does not create user' do
          expect do
            post :create, user: invalid_params
          end.to_not change(User, :count)
        end

        it 'renders "new" template' do
          post :create, user: invalid_params
          expect(response).to render_template('new')
        end

        it 'provides new user to the view' do
          post :create, user: invalid_params
          resource_user = controller.view_context.resource_user 
          expect(resource_user.email).to eq(invalid_params[:email])
          expect(resource_user.login).to eq(invalid_params[:login])
        end

        context 'when responding to JSON' do
          it 'returns 422 response' do
            post :create, user: invalid_params, format: :json
            expect(response.status).to eq(422)
          end

          it 'renders validation errors' do
            post :create, user: invalid_params, format: :json
            expect(response.body).to eq(controller.view_context.resource_user.errors.to_json)
          end
        end
      end
    end

    context 'when user is logged in' do
      let(:valid_params) { FactoryGirl.attributes_for :user }

      before do
        login
      end

      it 'redirects to home page' do
        post :create, user: valid_params
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET edit' do
    let(:user) { FactoryGirl.create :user }

    context 'when user is logged out' do
      it 'redirects to login page' do
        get :edit, id: user.id
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when different user is logged in' do
      it 'redirects to his own page' do
        another_user = FactoryGirl.create :user
        login_as another_user
        get :edit, id: user.id
        expect(response).to redirect_to(another_user)
      end
    end

    context 'when admin is logged in' do
      before do
        login_as_admin
      end

      it 'returns 200 response' do
        get :edit, id: user.id
        expect(response.status).to eq(200)
      end

      it 'provides requested user to the view' do
        get :edit, id: user.id
        expect(controller.view_context.resource_user).to eq(user)
      end
    end

    context 'when user does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          get :edit, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'returns 200 response' do
        get :edit, id: user.id
        expect(response.status).to eq(200)
      end

      it 'provides requested user to the view' do
        get :edit, id: user.id
        expect(controller.view_context.resource_user).to eq(user)
      end
    end
  end

  describe 'PATCH update' do
    let(:user) { FactoryGirl.create :user }

    context 'with valid params' do
      let(:valid_params) { FactoryGirl.attributes_for :user }

      context 'when user is logged out' do
        it 'does not update user' do
          previous_attributes = user.reload.attributes
          patch :update, id: user.id, user: valid_params
          expect(user.reload.attributes).to eq(previous_attributes)
        end

        it 'redirects to login page' do
          patch :update, id: user.id, user: valid_params
          expect(response).to redirect_to(login_url)
        end
      end

      context 'when different user is logged in' do
        let(:another_user) { FactoryGirl.create :user }

        before do
          login_as another_user
        end

        it 'does not update user' do
          previous_attributes = user.reload.attributes
          patch :update, id: user.id, user: valid_params
          expect(user.reload.attributes).to eq(previous_attributes)
        end

        it 'redirects to his own page' do
          patch :update, id: user.id, user: valid_params
          expect(response).to redirect_to(another_user)
        end

        context 'when responding to JSON' do
          it 'returns 401 response' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response.status).to eq(401)
          end

          it 'returns error message' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response.body).to eq({ error: 'Unauthorized' }.to_json)
          end
        end
      end

      context 'when admin is logged in' do
        before do
          login_as_admin
        end

        it 'updates user' do
          patch :update, id: user.id, user: valid_params
          user.reload
          expect(user.email).to eq(valid_params[:email])
          expect(user.login).to eq(valid_params[:login])
          expect(user.authenticate(valid_params[:password])).to eq(user)
        end

        it 'allows to change role' do
          role = Role.first
          params = valid_params.merge(role_id: role.id)
          expect do
            patch :update, id: user.id, user: params
            user.reload
          end.to change(user, :role).from(nil).to(role)
        end
        
        it 'redirects to updated user' do
          patch :update, id: user.id, user: valid_params
          expect(response).to redirect_to(user)
        end

        context 'when responding to JSON' do
          it 'returns 200 response' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response.status).to eq(200)
          end

          it 'renders "show" template' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response).to render_template('show')
          end

          it 'provides requested user to the view' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(controller.view_context.resource_user).to eq(User.last)
          end
        end
      end

      context 'when user is logged in' do
        before do
          login_as user
        end

        it 'updates user' do
          patch :update, id: user.id, user: valid_params
          user.reload
          expect(user.email).to eq(valid_params[:email])
          expect(user.login).to eq(valid_params[:login])
          expect(user.authenticate(valid_params[:password])).to eq(user)
        end

        it 'does not allow to change role' do
          role = Role.first
          params = valid_params.merge(role_id: role.id)
          expect do
            patch :update, id: user.id, user: params
            user.reload
          end.to_not change(user, :role)
        end
        
        it 'redirects to updated user' do
          patch :update, id: user.id, user: valid_params
          expect(response).to redirect_to(user)
        end

        context 'when responding to JSON' do
          it 'returns 200 response' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response.status).to eq(200)
          end

          it 'renders "show" template' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(response).to render_template('show')
          end

          it 'provides requested user to the view' do
            patch :update, id: user.id, user: valid_params, format: :json
            expect(controller.view_context.resource_user).to eq(User.last)
          end
        end
      end

      context 'when user does not exist' do
        it 'raises "ActiveRecord::RecordNotFound"' do
          expect do
            patch :update, id: 0, user: valid_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { FactoryGirl.attributes_for(:user).merge(email: 'invalid') }

      before do
        login_as user
      end

      it 'does not update user' do
        previous_attributes = user.reload.attributes
        patch :update, id: user.id, user: invalid_params
        expect(user.reload.attributes).to eq(previous_attributes)
      end

      it 'renders "edit" template' do
        patch :update, id: user.id, user: invalid_params
        expect(response).to render_template('edit')
      end

      it 'provides user to the view' do
        patch :update, id: user.id, user: invalid_params
        expect(controller.view_context.resource_user).to eq(user)
      end

      context 'when responding to JSON' do
        it 'returns 422 response' do
          patch :update, id: user.id, user: invalid_params, format: :json
          expect(response.status).to eq(422)
        end

        it 'renders validation errors' do
          patch :update, id: user.id, user: invalid_params, format: :json
          expect(response.body).to eq(controller.view_context.resource_user.errors.to_json)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:user) { FactoryGirl.create :user }

    context 'when user is logged out' do
      it 'does not destroy user' do
        expect do
          delete :destroy, id: user.id
        end.to_not change(User, :count)
      end

      it 'redirects to login page' do
        delete :destroy, id: user.id
        expect(response).to redirect_to(login_url)
      end

      context 'when responding to JSON' do
        it 'returns 401 response' do
          delete :destroy, id: user.id, format: :json
          expect(response.status).to eq(401)
        end

        it 'returns error message' do
          delete :destroy, id: user.id, format: :json
          expect(response.body).to eq({ error: 'Unauthorized' }.to_json)
        end
      end
    end

    context 'when different user is logged in' do
      let!(:another_user) { FactoryGirl.create :user }

      before do
        login_as another_user
      end

      it 'does not destroy user' do
        expect do
          delete :destroy, id: user.id
        end.to_not change(User, :count)
      end

      it 'redirects to his own page' do
        delete :destroy, id: user.id
        expect(response).to redirect_to(another_user)
      end

      context 'when responding to JSON' do
        it 'returns 401 response' do
          delete :destroy, id: user.id, format: :json
          expect(response.status).to eq(401)
        end

        it 'returns error message' do
          delete :destroy, id: user.id, format: :json
          expect(response.body).to eq({ error: 'Unauthorized' }.to_json)
        end
      end
    end

    context 'when admin is logged in' do
      before do
        login_as_admin
      end

      it 'destroys user' do
        expect do
          delete :destroy, id: user.id
        end.to change(User, :count).by(-1)
        expect do
          user.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it 'redirects to home page' do
        delete :destroy, id: user.id
        expect(response).to redirect_to(root_url)
      end

      context 'when responding to JSON' do
        it 'returns 204 response' do
          delete :destroy, id: user.id, format: :json
          expect(response.status).to eq(204)
        end
      end
    end

    context 'when user is logged in' do
      before do
        login_as user
      end

      it 'destroys user' do
        expect do
          delete :destroy, id: user.id
        end.to change(User, :count).by(-1)
        expect do
          user.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it 'redirects to home page' do
        delete :destroy, id: user.id
        expect(response).to redirect_to(root_url)
      end

      context 'when responding to JSON' do
        it 'returns 204 response' do
          delete :destroy, id: user.id, format: :json
          expect(response.status).to eq(204)
        end
      end
    end

    context 'when user does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          delete :destroy, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
