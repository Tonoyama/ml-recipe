class IngredientsController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_correct_customer, only: %i[edit update destroy]
  def ensure_correct_customer
    @recipe = Recipe.find(params[:recipe_id])
    redirect_to root_path if current_customer.id != @recipe.customer_id
  end

  def edit
    @recipe = Recipe.find(params[:recipe_id])
    @ingredients = Ingredient.where(recipe_id: @recipe.id).order(:position)
    @ingredient = Ingredient.new
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @ingredient = Ingredient.new(ingredient_params)
    @ingredients = @recipe.ingredients.all
    if @ingredient.save
      if @recipe.recipe_status == 'レシピ'
        @recipe.update(recipe_status: '材料')
      elsif (@recipe.recipe_status == '未入力あり') && @recipe.cookings.present?
        @recipe.update(recipe_status: '準備中')
      end
    end
  end

  def update
    @ingredient = Ingredient.find(params[:id])
    @ingredients = @recipe.ingredients
    @recipe = Recipe.find(params[:recipe_id])
    flash.now[:update] = 'UPDATE !' if @ingredient.update(ingredient_params)
  end

  def destroy
    @recipe = Recipe.find(params[:recipe_id])
    @ingredient = Ingredient.find(params[:id])
    @ingredients = @recipe.ingredients.all
    if @ingredient.destroy
      if @recipe.ingredients.empty?
        if (@recipe.recipe_status == '完成') || (@recipe.recipe_status == '準備中')
          @recipe.update(recipe_status: '未入力あり')
          flash[:notice] = '材料が入力されていません。確認して下さい'
        end
      end
    end
  end

  def move
    @recipe = Recipe.find(params[:recipe_id])
    @ingredient = Ingredient.find(params[:id])
    @ingredients = @recipe.ingredients
    if params[:move]
      if params[:move] == 'up'
        @ingredient.move_higher
      else
        @ingredient.move_lower
      end
    end
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:recipe_id, :content, :amount)
  end
end
