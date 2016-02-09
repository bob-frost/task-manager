require 'rails_helper'

RSpec.describe Web::TasksController, type: :controller do
  describe 'GET index' do
    it 'returns 200 response' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'provides tasks to the view' do
      2.times { FactoryGirl.create :task }
      get :index
      expect(controller.view_context.resource_collection.to_a).to eq(Task.order('created_at DESC').to_a)
    end
  end

  describe 'GET show' do
    context 'when task exists' do
      let(:task) { FactoryGirl.create :task }

      it 'returns 200 response' do
        get :show, id: task.id
        expect(response.status).to eq(200)
      end

      it 'provides requested task to the view' do
        get :show, id: task.id
        expect(controller.view_context.resource_task).to eq(task)
      end
    end

    context 'when task does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          get :show, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET new' do
    context 'when user is logged out' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user is logged in' do
      before do
        login
      end

      it 'returns 200 response' do
        get :new
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'POST create' do
    context 'when user is logged out' do
      let(:valid_params) { FactoryGirl.attributes_for :task }

      it 'redirects to login page' do
        post :create, task: valid_params
        expect(response).to redirect_to(login_url)
      end

      it 'does not create task' do
        expect do
          post :create, task: valid_params
        end.to_not change(Task, :count)
      end
    end

    context 'when user is logged in' do
      let(:user) { FactoryGirl.create :user }

      before do
        login_as user
      end

      context 'with valid params' do
        let(:valid_params) { FactoryGirl.attributes_for :task }

        it 'creates new task' do
          expect do
            post :create, task: valid_params
          end.to change(Task, :count).by 1
        end

        it 'assigns correct attributes' do
          post :create, task: valid_params
          task = Task.last
          expect(task.name).to eq(valid_params[:name])
          expect(task.description).to eq(valid_params[:description])
        end

        it 'assigns current user as an owner to the task' do
          post :create, task: valid_params
          task = Task.last
          expect(task.user).to eq(user)
        end

        it 'does not allow to set user' do
          another_user = FactoryGirl.create :user
          post :create, task: valid_params.merge(user_id: another_user.id)
          task = Task.last
          expect(task.user).to eq(user)
        end

        it 'allows to set assignee' do
          another_user = FactoryGirl.create :user
          post :create, task: valid_params.merge(assignee_id: another_user.id)
          task = Task.last
          expect(task.assignee).to eq(another_user)
        end

        it 'allows to set attachment' do
          file = Rack::Test::UploadedFile.new "#{Rails.root}/spec/files/task_attachment.txt", 'text/plain'
          post :create, task: valid_params.merge(attachment: file)
          task = Task.last
          expect(task.attachment).to be_present
        end

        it 'redirects to task page' do
          post :create, task: valid_params
          task = Task.last
          expect(response).to redirect_to(task)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) { FactoryGirl.attributes_for(:task).merge(name: '') }

        it 'does not create new task' do
          expect do
            post :create, task: invalid_params
          end.to_not change(Task, :count)
        end

        it 'renders "new" template' do
          post :create, task: invalid_params
          expect(response).to render_template('new')
        end

        it 'provides new task to the view' do
          post :create, task: invalid_params
          resource_task = controller.view_context.resource_task 
          expect(resource_task.name).to eq(invalid_params[:name])
          expect(resource_task.description).to eq(invalid_params[:description])
        end
      end
    end
  end

  describe 'GET edit' do
    let(:user) { FactoryGirl.create :user }
    let(:task) { FactoryGirl.create :task, user: user }

    context 'when user is logged out' do
      it 'redirects to login page' do
        get :edit, id: task.id
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user different from task owner is logged in' do
      it 'redirects to his own page' do
        another_user = FactoryGirl.create :user
        login_as another_user
        get :edit, id: task.id
        expect(response).to redirect_to(another_user)
      end
    end

    context 'when admin is logged in' do
      before do
        login_as_admin
      end

      it 'returns 200 response' do
        get :edit, id: task.id
        expect(response.status).to eq(200)
      end

      it 'provides requested task to the view' do
        get :edit, id: task.id
        expect(controller.view_context.resource_task).to eq(task)
      end
    end

    context 'when task does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          get :edit, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when task owner is logged in' do
      before do
        login_as user
      end

      it 'returns 200 response' do
        get :edit, id: task.id
        expect(response.status).to eq(200)
      end

      it 'provides requested task to the view' do
        get :edit, id: task.id
        expect(controller.view_context.resource_task).to eq(task)
      end
    end
  end

  describe 'PATCH update' do
    let(:user) { FactoryGirl.create :user }
    let(:task) { FactoryGirl.create :task, user: user }

    context 'with valid params' do
      let(:valid_params) { FactoryGirl.attributes_for :task }

      context 'when user is logged out' do
        it 'does not update task' do
          previous_attributes = task.reload.attributes
          patch :update, id: task.id, task: valid_params
          expect(task.reload.attributes).to eq(previous_attributes)
        end

        it 'redirects to login page' do
          patch :update, id: task.id, task: valid_params
          expect(response).to redirect_to(login_url)
        end
      end

      context 'when user different from task owner is logged in' do
        let(:another_user) { FactoryGirl.create :user }

        before do
          login_as another_user
        end

        it 'does not update task' do
          previous_attributes = task.reload.attributes
          patch :update, id: task.id, task: valid_params
          expect(task.reload.attributes).to eq(previous_attributes)
        end

        it 'redirects to his own page' do
          patch :update, id: task.id, task: valid_params
          expect(response).to redirect_to(another_user)
        end
      end

      context 'when admin is logged in' do
        before do
          login_as_admin
        end

        it 'updates task' do
          patch :update, id: task.id, task: valid_params
          task.reload
          expect(task.name).to eq(valid_params[:name])
          expect(task.description).to eq(valid_params[:description])
        end

        it 'does not allow to change user' do
          another_user = FactoryGirl.create :user
          expect do
            patch :update, id: task.id, task: valid_params.merge(user_id: another_user.id)
          end.to_not change(task, :user)
        end

        it 'allows to change assignee' do
          another_user = FactoryGirl.create :user
          expect do
            patch :update, id: task.id, task: valid_params.merge(assignee_id: another_user.id)
            task.reload
          end.to change(task, :assignee).from(nil).to(another_user)
        end

        it 'allows to set attachment' do
          file = Rack::Test::UploadedFile.new "#{Rails.root}/spec/files/task_attachment.txt", 'text/plain'
          expect do
            patch :update, id: task.id, task: valid_params.merge(attachment: file)
            task.reload
          end.to change { task.attachment.present? }.from(false).to(true)
        end
        
        it 'redirects to updated task' do
          patch :update, id: task.id, task: valid_params
          expect(response).to redirect_to(task)
        end
      end

      context 'when task owner is logged in' do
        before do
          login_as user
        end

        it 'updates task' do
          patch :update, id: task.id, task: valid_params
          task.reload
          expect(task.name).to eq(valid_params[:name])
          expect(task.description).to eq(valid_params[:description])
        end

        it 'does not allow to change user' do
          another_user = FactoryGirl.create :user
          expect do
            patch :update, id: task.id, task: valid_params.merge(user_id: another_user.id)
          end.to_not change(task, :user)
        end

        it 'allows to change assignee' do
          another_user = FactoryGirl.create :user
          expect do
            patch :update, id: task.id, task: valid_params.merge(assignee_id: another_user.id)
            task.reload
          end.to change(task, :assignee).from(nil).to(another_user)
        end

        it 'allows to set attachment' do
          file = Rack::Test::UploadedFile.new "#{Rails.root}/spec/files/task_attachment.txt", 'text/plain'
          expect do
            patch :update, id: task.id, task: valid_params.merge(attachment: file)
            task.reload
          end.to change { task.attachment.present? }.from(false).to(true)
        end
        
        it 'redirects to updated task' do
          patch :update, id: task.id, task: valid_params
          expect(response).to redirect_to(task)
        end
      end

      context 'when task does not exist' do
        it 'raises "ActiveRecord::RecordNotFound"' do
          expect do
            patch :update, id: 0, task: valid_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { FactoryGirl.attributes_for(:task).merge(name: '') }

      before do
        login_as user
      end

      it 'does not update task' do
        previous_attributes = task.reload.attributes
        patch :update, id: task.id, task: invalid_params
        expect(task.reload.attributes).to eq(previous_attributes)
      end

      it 'renders "edit" template' do
        patch :update, id: task.id, task: invalid_params
        expect(response).to render_template('edit')
      end

      it 'provides task to the view' do
        patch :update, id: task.id, task: invalid_params
        expect(controller.view_context.resource_task).to eq(task)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:user) { FactoryGirl.create :user }
    let!(:task) { FactoryGirl.create :task, user: user }

    context 'when user is logged out' do
      it 'does not destroy task' do
        expect do
          delete :destroy, id: task.id
        end.to_not change(Task, :count)
      end

      it 'redirects to login page' do
        delete :destroy, id: task.id
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user different from task owner is logged in' do
      let(:another_user) { FactoryGirl.create :user }

      before do
        login_as another_user
      end

      it 'does not destroy task' do
        expect do
          delete :destroy, id: task.id
        end.to_not change(Task, :count)
      end

      it 'redirects to his own page' do
        delete :destroy, id: task.id
        expect(response).to redirect_to(another_user)
      end
    end

    context 'when admin is logged in' do
      let(:user) { FactoryGirl.create :admin }
      
      before do
        login_as user
      end

      it 'destroys task' do
        expect do
          delete :destroy, id: task.id
        end.to change(Task, :count).by(-1)
        expect do
          task.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it "redirects to current user's tasks page" do
        delete :destroy, id: task.id
        expect(response).to redirect_to(user_tasks_url(user))
      end
    end

    context 'when task owner is logged in' do
      before do
        login_as user
      end

      it 'destroys task' do
        expect do
          delete :destroy, id: task.id
        end.to change(Task, :count).by(-1)
        expect do
          task.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
      
      it "redirects to current user's tasks page" do
        delete :destroy, id: task.id
        expect(response).to redirect_to(user_tasks_url(user))
      end
    end

    context 'when task does not exist' do
      it 'raises "ActiveRecord::RecordNotFound"' do
        expect do
          delete :destroy, id: 0
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH next_state' do
    context 'when user is logged out' do
      let(:task) { FactoryGirl.create :task }

      it 'does not change state' do
        expect do
          patch :next_state, id: task.id
          task.reload
        end.to_not change(task, :state)
      end

      it 'redirects to login page' do
        patch :next_state, id: task.id
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user different from task owner is logged in' do
      let(:task) { FactoryGirl.create :task }
      let(:another_user) { FactoryGirl.create :user }

      before do
        login_as another_user
      end

      it 'does not change state' do
        expect do
          patch :next_state, id: task.id
          task.reload
        end.to_not change(task, :state)
      end

      it 'redirects to his own page' do
        patch :next_state, id: task.id
        expect(response).to redirect_to(another_user)
      end
    end

    context 'when admin is logged in' do
      before do
        login_as_admin
      end

      context 'when state is "todo"' do
        let(:task) { FactoryGirl.create :task, state: 'todo' }

        it 'changes state to "started"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('todo').to('started')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end

      context 'when state is "started"' do
        let(:task) { FactoryGirl.create :task, state: 'started' }

        it 'changes state to "finished"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('started').to('finished')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end

      context 'when state is "finished"' do
        let(:task) { FactoryGirl.create :task, state: 'finished' }

        it 'changes state back to "todo"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('finished').to('todo')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end
    end

    context 'when task owner is logged in' do
      let(:user) { FactoryGirl.create :user }
      
      before do
        login_as user
      end

      context 'when state is "todo"' do
        let(:task) { FactoryGirl.create :task, user: user, state: 'todo' }

        it 'changes state to "started"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('todo').to('started')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end

      context 'when state is "started"' do
        let(:task) { FactoryGirl.create :task, user: user, state: 'started' }

        it 'changes state to "finished"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('started').to('finished')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end

      context 'when state is "finished"' do
        let(:task) { FactoryGirl.create :task, user: user, state: 'finished' }

        it 'changes state back to "todo"' do
          expect do
            patch :next_state, id: task.id
            task.reload
          end.to change(task, :state).from('finished').to('todo')
        end

        it 'redirects to task page' do
          patch :next_state, id: task.id
          expect(response).to redirect_to(task)
        end
      end
    end
  end
end
