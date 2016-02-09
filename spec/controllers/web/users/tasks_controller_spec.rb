require 'rails_helper'

RSpec.describe Web::Users::TasksController, type: :controller do
  describe 'GET index' do
    context 'when user is logged out' do
      context "when resource_user is not admin" do
        let(:resource_user) { FactoryGirl.create :user }

        it 'provides tasks associated with resource_user to the view' do
          owned_task = FactoryGirl.create :task, user: resource_user
          assigned_task = FactoryGirl.create :task, assignee: resource_user
          not_associated_task = FactoryGirl.create :task
          get :index, user_id: resource_user.id
          expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
        end
      end

      context 'when resource_user is admin' do
        let(:resource_user) { FactoryGirl.create :admin }

        it 'provides tasks associated with resource_user to the view' do
          owned_task = FactoryGirl.create :task, user: resource_user
          assigned_task = FactoryGirl.create :task, assignee: resource_user
          not_associated_task = FactoryGirl.create :task
          get :index, user_id: resource_user.id
          expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
        end
      end

      context 'when admin is logged in' do
        let(:user) { FactoryGirl.create :admin }

        before do
          login_as user
        end

        context 'when resource_user is admin himself' do
          it 'provides all tasks to the view' do
            owned_task = FactoryGirl.create :task, user: user
            assigned_task = FactoryGirl.create :task, assignee: user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: user.id
            expect(controller.view_context.resource_collection.to_a).to eq([not_associated_task, assigned_task, owned_task])
          end
        end

        context 'when resource_user is another admin' do
          it 'provides tasks associated with resource_user to the view' do
            resource_user = FactoryGirl.create :admin
            owned_task = FactoryGirl.create :task, user: resource_user
            assigned_task = FactoryGirl.create :task, assignee: resource_user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: resource_user.id
            expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
          end
        end

        context 'when resource_user is not admin' do
          it 'provides tasks associated with resource_user to the view' do
            resource_user = FactoryGirl.create :admin
            owned_task = FactoryGirl.create :task, user: resource_user
            assigned_task = FactoryGirl.create :task, assignee: resource_user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: resource_user.id
            expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
          end
        end
      end

      context 'when user is logged in' do
        let(:user) { FactoryGirl.create :user }

        before do
          login_as user
        end

        context 'when resource_user is user himself' do
          it 'provides tasks associated with resource_user to the view' do
            owned_task = FactoryGirl.create :task, user: user
            assigned_task = FactoryGirl.create :task, assignee: user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: user.id
            expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
          end
        end

        context 'when resource_user is admin' do
          it 'provides tasks associated with resource_user to the view' do
            resource_user = FactoryGirl.create :admin
            owned_task = FactoryGirl.create :task, user: resource_user
            assigned_task = FactoryGirl.create :task, assignee: resource_user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: resource_user.id
            expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
          end
        end

        context 'when resource_user is another user' do
          it 'provides tasks associated with resource_user to the view' do
            resource_user = FactoryGirl.create :user
            owned_task = FactoryGirl.create :task, user: resource_user
            assigned_task = FactoryGirl.create :task, assignee: resource_user
            not_associated_task = FactoryGirl.create :task
            get :index, user_id: resource_user.id
            expect(controller.view_context.resource_collection.to_a).to eq([assigned_task, owned_task])
          end
        end
      end
    end
  end
end
