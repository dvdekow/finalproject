class NodesController < ApplicationController
  def index
    @nodes = Node.all
  end

  def new
    @node = Node.new
  end

  def create
    @node = Node.new(params[:node])
  end
end