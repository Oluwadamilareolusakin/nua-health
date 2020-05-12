require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let!(:doctor) { create(:doctor) }
  let!(:admin) { create(:admin) }
  let!(:patient) { create(:patient) }
  let(:message) { create(:message) }
  
  describe '#create' do
    before do
      admin.inbox = Inbox.create!(user: admin)
      doctor.inbox = Inbox.create!(user: doctor)
      doctor.outbox = Outbox.create!(user: doctor)
      patient.outbox = create(:outbox)
      patient.inbox = create(:inbox)
    end
    
    context 'when message is created' do
      before do
        @prev_count = doctor.inbox.unread?
        post :create, params: { id: patient.id, message_id: message.id, message: { body: "Some fancy message" } } 
      end
      
      it 'should have the read attribute set to false' do
        expect(doctor.inbox.messages.last.read).to eq(false)
      end
      
      it 'should increase unread message count' do
        expect(doctor.inbox.unread?).to eq(@prev_count + 1)
      end
      
      context 'when initial message was sent within the week' do
        
        before { post :create, params: { id: patient.id, message_id: message.id, message: { body: "Some fancy message" } } }
        
        it 'should be sent to the doctor inbox' do
          expect(doctor.inbox.messages.last).to eq(patient.outbox.messages.last)
        end
      end
      
      context 'when initial message was sent more than a week ago' do
        before { 
          message.update_attribute(:created_at, 1.month.ago) 
          message.save
          post :create, params: {id: patient.id, message_id: message.id, message: { body: "Some fancy message" } } 
        }
        
        it 'should be sent to admin inbox' do
          expect(admin.inbox.messages.last).to eq(patient.outbox.messages.last)
        end
      end
    end
  end
  
  describe '#show' do
    before do
      doctor.inbox = create(:inbox)
      patient.outbox = create(:outbox)
      @message = Message.create({body: "hey", inbox: doctor.inbox, outbox: patient.outbox})
      @message.save!
      @prev_count = doctor.inbox.unread?
    end
    
    context 'when message is unread' do
      before { get :show, params: {id: @message.id} }

      it 'should decrement the unread message count' do
        expect(doctor.inbox.unread?).to eq(@prev_count - 1)
      end
    end
  end

  describe '#request_prescription' do
    before do 
      admin.inbox = create(:inbox)
      patient.outbox = create(:outbox)
      @prev_count = admin.inbox.unread?
      @payments_count = Payment.count
    end
    
    context 'request is successfull' do
      before do
        post :request_prescription, params: {id: patient.id} 
      end

      it 'should decrement the unread message count' do
        expect(admin.inbox.unread?).to eq(@prev_count + 1)
      end
      
      it 'should create a payment record' do
        expect(Payment.count).to eq(@payments_count + 1)
      end
    end


    context 'when there is an exception' do
      
      it 'should handle exceptions' do
        expect(post :request_prescription, params: {id: doctor.id})
          .to render_template(:show)
      end

      it 'should delete the message' do
        expect(admin.inbox.unread?).to eq(@prev_count)
      end
    end
  end
  
  
end