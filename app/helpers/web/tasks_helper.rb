module Web
  module TasksHelper

    STATE_LABEL_CSS_CLASSES = {
      todo: 'default',
      started: 'primary',
      finished: 'success'
    }.with_indifferent_access

    NEXT_STATE_BUTTON_CSS_CLASSES = {
      todo: 'primary',
      started: 'success',
      finished: 'default'
    }.with_indifferent_access

    def assignee_collection_for_select
      User.order :name
    end

    def task_state_label(task, options = {})
      css_class = "label label-#{STATE_LABEL_CSS_CLASSES[task.state]}"
      options[:class] = [css_class, options[:class]].compact.join ' '
      content_tag :span, options  do
        t "task_states.names.#{task.state}"
      end
    end

    def task_next_state_button(task, options = {})
      css_class = "btn btn-#{NEXT_STATE_BUTTON_CSS_CLASSES[task.state]}"
      options[:class] = [css_class, options[:class]].compact.join ' '
      options[:method] = :patch
      link_to next_state_task_path(task), options do
        t "task_states.next_actions.#{task.state}"
      end
    end
  end
end
