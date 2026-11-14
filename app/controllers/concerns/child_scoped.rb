module ChildScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_child
  end

  private

  def set_child
    @child = Child.find(params[:child_id])
  end
end
