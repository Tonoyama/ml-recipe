class HomesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def top
    @recipes = Recipe.where(recipe_status: '完成')
    @products = Product.where(is_active: '販売中')
  end

  def about; end

  def new_guest
    customer = Customer.find_by!(email: 'gest@gest') do |gest|
      gest.password = gestgest
      gest.account_name = 'ゲストユーザー'
    end
    sign_in customer
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました'
  end

  def new_admin
    admin = Admin.find_by!(email: 'admin@admin') do |gest_admin|
      gest_admin.password = adminadmin
    end
    sign_in admin
    redirect_to admins_top_path, notice: '管理者としてログインしました'
  end
end
