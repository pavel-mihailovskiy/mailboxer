require 'spec_helper'

describe Message do
  
  before do
    User.stub(:blockers_of).and_return([])
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)
    @receipt1 = @entity1.send_message(@entity2,"Body","Subject")
    @receipt2 = @entity2.reply_to_all(@receipt1,"Reply body 1")
    @receipt3 = @entity1.reply_to_all(@receipt2,"Reply body 2")
    @receipt4 = @entity2.reply_to_all(@receipt3,"Reply body 3")
    @message1 = @receipt1.notification
    @message4 = @receipt4.notification
    @conversation = @message1.conversation
  end  
  
  it "should have right recipients" do
  	@receipt1.notification.recipients.count.should==2
  	@receipt2.notification.recipients.count.should==2
  	@receipt3.notification.recipients.count.should==2
  	@receipt4.notification.recipients.count.should==2      
  end

  describe 'send_at' do
    it 'should return date with time' do
      @message1.created_at = Date.yesterday.to_datetime
      expect(@message1.send_at).to eq(Date.yesterday.strftime("%B %e, %Y %H:%M:%S"))
    end

    it 'should return time' do
      expect(@message1.send_at).to eq(@message1.created_at.strftime('%H:%M:%S').lstrip)
    end
  end

  describe 'sender_name' do
    it 'should return sender_name' do
      User.any_instance.stub(:fullname).and_return(@entity1.name)
      @message1.created_at = Date.yesterday.to_datetime
      expect(@message1.sender.name).to eq(@entity1.name)
    end
  end
end
