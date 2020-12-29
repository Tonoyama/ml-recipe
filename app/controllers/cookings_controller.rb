class CookingsController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_correct_customer, only: %i[edit update destroy]
  def ensure_correct_customer
    @recipe = Recipe.find(params[:recipe_id])
    redirect_to root_path if current_customer.id != @recipe.customer_id
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @cooking = Cooking.new(cooking_params)
    @cookings = @recipe.cookings.all
    if @cooking.save
      if @recipe.recipe_status == '材料'
        @recipe.update(recipe_status: '作り方')
      elsif (@recipe.recipe_status == '未入力あり') && @recipe.ingredients.present?
        @recipe.update(recipe_status: '準備中')
      end
    end
  end

  def edit
    @recipe = Recipe.find(params[:recipe_id])
    @cooking = Cooking.new
    @cookings = Cooking.where(recipe_id: @recipe.id).order(:position)
  end

  def update
    @cooking = Cooking.find(params[:id])
    @cookings = @recipe.cookings.all
    @recipe = Recipe.find(params[:recipe_id])
    flash.now[:update] = 'UPDATE !' if @cooking.update(cooking_params)
  end

  def destroy
    @recipe = Recipe.find(params[:recipe_id])
    @cooking = Cooking.find(params[:id])
    @cookings = @recipe.cookings.all
    if @cooking.destroy
      if @recipe.cookings.empty?
        if (@recipe.recipe_status == '完成') || (@recipe.recipe_status == '準備中')
          @recipe.update(recipe_status: '未入力あり')
          flash[:notice] = '作り方が入力されていません。確認して下さい'
        end
      end
    end
  end

  def move
    @recipe = Recipe.find(params[:recipe_id])
    @cooking = Cooking.find(params[:id])
    @cookings = @recipe.cookings
    if params[:move]
      if params[:move] == 'up'
        @cooking.move_higher
      else
        @cooking.move_lower
      end
    end
  end

  private

  def cooking_params
    params.require(:cooking).permit(:recipe_id, :content)
  end
end
