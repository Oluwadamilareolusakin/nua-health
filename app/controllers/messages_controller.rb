class MessagesController < ApplicationController
  before_action :set_user, only: %i[ create request_prescription ]
  before_action :set_initial_message, only: %i[ new create ]

  def show
    @message = Message.find(params[:id])
    if @message.unread?
      @message.mark_as_read
    end
  end

  def new
    @message = Message.new
    
    @inbox = Inbox.find(params[:inbox_id]) 
    @user = @inbox.user
    @initial_message = Message.find(params[:message_id])
  end

  def create
    message = @user.outbox.messages.create(message_params)

    if @initial_message.current?
      message.inbox = User.default_doctor.inbox
    elsif @initial_message.stale?
      message.inbox = User.default_admin.inbox
    end
    
    if message.save
      redirect_to messages_path
    else
      render :new
    end
  end

  def request_prescription
    message = User.default_admin.inbox.messages.create({body: "I need a new one guys", outbox: @user.outbox})
    message.save
    
    begin
      PaymentProviderFactory.provider.debit_card(@user)
      payment = @user.payments.create!
      render :index
    rescue => exception
      message.delete
      render :show
    end
    
  end


  private 

  def message_params
    params.require(:message).permit(:body)
  end

  def set_initial_message
    @initial_message = Message.find(params[:message_id])
  end

  def set_user
    @user = User.find(params[:id])
  end

end
