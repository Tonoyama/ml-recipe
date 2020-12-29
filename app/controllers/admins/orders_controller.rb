class Admins::OrdersController < ApplicationController
  before_action :authenticate_admin!
  def top
    @orders = Order.where(created_at: Time.zone.now.all_day)
    @reviews = Review.where(created_at: Time.zone.now.all_day)
    @all_reviews = Review.all
    @good_reviews = Review.where('score >= ?', 0)
    @bad_reviews = Review.where('score < ?', 0)
  end

  def index
    @search = Order.ransack(params[:q])
    if params[:customer_id]
      @customer = Customer.with_deleted.find(params[:customer_id])
      @orders = Order.where(customer_id: @customer.id).order(id: 'DESC').page(params[:page]).per(15)
      @order_title = '注文一覧/' + @customer.name + ' 様'
    elsif params[:q]
      @orders = @search.result(distinct: true).page(params[:page]).per(15)
      @order_title = '注文一覧/検索：' + @search.name_or_address_or_customer_name_cont
    else
      @orders = Order.all.order(id: 'DESC').page(params[:page]).per(15)
      @order_title = '注文一覧'
    end
  end

  def show
    @order = Order.find(params[:id])
    @order_details = OrderDetail.where(order_id: @order.id)
  end

  def update
    @order = Order.find(params[:id])
    @order_details = OrderDetail.where(order_id: @order.id)
    @order.update(order_params)
    if @order.order_status == '入金確認'
      @order_details.each do |order_detail|
        order_detail.update(work_status: '準備待ち')
      end
    end
    redirect_to admins_order_path(@order)
  end

  def order_params
    params.require(:order).permit(:order_status)
  end
end
