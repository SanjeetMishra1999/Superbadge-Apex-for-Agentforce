public class GuestReviewProcessor {
    @InvocableMethod(
        label='Process Guest Reviews'
        description='Processes guest reviews and creates campaign members for related campaigns.'
    )
    public static List<GuestReviewResponse> processReviews(List<GuestReviewRequest> requests) {
        List<GuestReviewResponse> responses = new List<GuestReviewResponse>();
        
        for (GuestReviewRequest request : requests) {
            GuestReviewResponse response = new GuestReviewResponse();
            
            try {
                // Create and insert the guest review record
                Guest_Review__c guestReview = new Guest_Review__c();
                guestReview.Contact__c = request.contact.Id;
                guestReview.Experience__c = request.experience.Id;
                guestReview.Rating__c = request.rating;
                guestReview.Comments__c = request.review;
                
                Database.insert(guestReview);
                
                // Create campaign members for related campaigns
                Map<Id, Contact> recurringCampaignParticipantByContactId = new Map<Id, Contact>();
                recurringCampaignParticipantByContactId.put(request.contact.Id, request.contact);
                CampaignMemberController.createCampaignMemberforRelatedCampaigns(recurringCampaignParticipantByContactId);
                
                response.message = 'Success';
                response.isSuccess = true;
                
            } catch (Exception e) {
                response.message = 'Error: ' + e.getMessage();
                response.isSuccess = false;
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    public class GuestReviewRequest {
        @InvocableVariable(
            required=true
            label='Contact Record'
            description='The contact associated with the guest review.'
        )
        public Contact contact;
        
        @InvocableVariable(
            required=true
            label='Experience Record'
            description='The experience being reviewed.'
        )       
        public Experience__c experience;
        
        @InvocableVariable(
            required=true
            label='Review Comments'
            description='The review comments text.'
        )
        public String review;
        
        @InvocableVariable(
            required=true
            label='Rating'
            description='The rating value for the experience.'
        )
        public String rating;
    }
    
    public class GuestReviewResponse {
        @InvocableVariable(
            label='Status'
            description='The status message indicating success or error details of the operation.'
        )
        public String message;
        
        @InvocableVariable(
            label='Is Success'
            description='Boolean indicating whether the operation was successful.'
        )
        public Boolean isSuccess;
    }    
}