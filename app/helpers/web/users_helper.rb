module Web
  module UsersHelper
    def roles_collection_for_select
      Role.all
    end
  end
end
