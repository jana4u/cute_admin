require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:<%= plural_name %>)
    assert_not_nil assigns(:<%= plural_name %>_count)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create <%= singular_name %>" do
    assert_difference('<%= model_name %>.count') do
      post :create, :<%= singular_name %> => { }
    end

    assert_redirected_to <%= singular_route %>(assigns(:<%= singular_name %>))
  end

  test "should show <%= singular_name %>" do
    get :show, :id => <%= plural_name %>(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => <%= plural_name %>(:one).id
    assert_response :success
  end

  test "should update <%= singular_name %>" do
    put :update, :id => <%= plural_name %>(:one).id, :<%= singular_name %> => { }
    assert_redirected_to <%= singular_route %>(assigns(:<%= singular_name %>))
  end

  test "should destroy <%= singular_name %>" do
    assert_difference('<%= model_name %>.count', -1) do
      delete :destroy, :id => <%= plural_name %>(:one).id
    end

    assert_redirected_to <%= plural_route %>
  end
end
