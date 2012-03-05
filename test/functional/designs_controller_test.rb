require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Design.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Design.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Design.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to design_url(assigns(:design))
  end

  def test_edit
    get :edit, :id => Design.first
    assert_template 'edit'
  end

  def test_update_invalid
    Design.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Design.first
    assert_template 'edit'
  end

  def test_update_valid
    Design.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Design.first
    assert_redirected_to design_url(assigns(:design))
  end

  def test_destroy
    design = Design.first
    delete :destroy, :id => design
    assert_redirected_to designs_url
    assert !Design.exists?(design.id)
  end
end
