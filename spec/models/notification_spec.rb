require 'spec_helper'

describe Message do

  describe 'No user in black list' do
    before do
      User.stub(:blockers_of).and_return([])
      @entity1 = FactoryGirl.create(:user)
      @entity2 = FactoryGirl.create(:user)
      @entity3 = FactoryGirl.create(:user)
    end  
    
    it "should notify one user" do
      @entity1.notify("Subject","Body")
      
      #Check getting ALL receipts
      @entity1.mailbox.receipts.size.should==1
      receipt = @entity1.mailbox.receipts.first
      notification = receipt.notification
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      
      #Check getting NOTIFICATION receipts only
      @entity1.mailbox.notifications.size.should==1
      notification = @entity1.mailbox.notifications.first
      notification.subject.should=="Subject"
      notification.body.should=="Body"       
    end

    it "should be unread by default" do
      @entity1.notify("Subject", "Body")
      @entity1.mailbox.receipts.size.should==1
      notification = @entity1.mailbox.receipts.first.notification
      notification.should be_is_unread(@entity1)
    end

    it "should be able to marked as read" do
      @entity1.notify("Subject", "Body")
      @entity1.mailbox.receipts.size.should==1
      notification = @entity1.mailbox.receipts.first.notification
      notification.mark_as_read(@entity1)
      notification.should be_is_read(@entity1)
    end
    
    it "should notify several users" do
      recipients = Set.new [@entity1,@entity2,@entity3]
      Notification.notify_all(recipients,"Subject","Body")
      
      #Check getting ALL receipts
      @entity1.mailbox.receipts.size.should==1
      receipt = @entity1.mailbox.receipts.first
      notification = receipt.notification
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      @entity2.mailbox.receipts.size.should==1
      receipt = @entity2.mailbox.receipts.first
      notification = receipt.notification
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      @entity3.mailbox.receipts.size.should==1
      receipt = @entity3.mailbox.receipts.first
      notification = receipt.notification
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      
      #Check getting NOTIFICATION receipts only
      @entity1.mailbox.notifications.size.should==1
      notification = @entity1.mailbox.notifications.first
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      @entity2.mailbox.notifications.size.should==1
      notification = @entity2.mailbox.notifications.first
      notification.subject.should=="Subject"
      notification.body.should=="Body"
      @entity3.mailbox.notifications.size.should==1
      notification = @entity3.mailbox.notifications.first
      notification.subject.should=="Subject"
      notification.body.should=="Body"
            
    end

    it "should notify a single recipient" do
      Notification.notify_all(@entity1,"Subject","Body")

      #Check getting ALL receipts
      @entity1.mailbox.receipts.size.should==1
      receipt = @entity1.mailbox.receipts.first
      notification = receipt.notification
      notification.subject.should=="Subject"
      notification.body.should=="Body"

      #Check getting NOTIFICATION receipts only
      @entity1.mailbox.notifications.size.should==1
      notification = @entity1.mailbox.notifications.first
      notification.subject.should=="Subject"
      notification.body.should=="Body"
    end
  end

  describe 'user has users in black list' do
    let(:user) { FactoryGirl.create(:user) }
    let(:friend) { FactoryGirl.create(:user) }
    let(:receipt) { user.send_message(friend, "body", "subject", true, nil )}

    before do
      User.stub(:blockers_of).and_return([])
      User.any_instance.stub(:blocked_users).and_return([])
    end

    it "should check recipients for black list" do
      friend.blocked_users << user
      expect(receipt.errors[:"notification.recipients"]).to be_true
    end    
  end
end
