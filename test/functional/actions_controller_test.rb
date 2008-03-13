require File.dirname(__FILE__) + '/../test_helper'
require 'actions_controller'

# Re-raise errors caught by the controller.
class ActionsController; def rescue_action(e) raise e end; end

class ActionsControllerTest < Test::Unit::TestCase
  fixtures :actions

  def setup
    @controller = ActionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:actions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_action
    old_count = Action.count
    post :create, :action => { }
    assert_equal old_count + 1, Action.count

    assert_redirected_to action_path(assigns(:action))
  end

  def test_should_show_action
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_action
    put :update, :id => 1, :action => { }
    assert_redirected_to action_path(assigns(:action))
  end

  def test_should_destroy_action
    old_count = Action.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Action.count

    assert_redirected_to actions_path
  end
end
