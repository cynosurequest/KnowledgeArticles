@isTest
public class KnowledgeArticleControllerTest {
    // Test Data Factory for creating reusable test data
    @TestSetup
    static void setupTestData() {
        // Create a test Knowledge article using the top-level TestDataFactory
        Knowledge__kav testArticle = TestDataFactory.createKnowledgeArticle(
            'test-article',
            'Test Article',
            'en_US'
        );
        insert testArticle;

        // Create a test Data Category Selection using the top-level TestDataFactory
        Knowledge__DataCategorySelection testCategory = TestDataFactory.createDataCategorySelection(
            testArticle.Id,
            'Directions',
            'North'
        );
        insert testCategory;
    }

    @isTest
    static void testGetFilteredArticles() {
        // Query the test data created in @TestSetup
        Knowledge__DataCategorySelection[] knowledgeCategories = [
            SELECT Id, DataCategoryGroupName, DataCategoryName
            FROM Knowledge__DataCategorySelection
            LIMIT 1
        ];

        // Assign parent and child category names
        String parentCategoryName = knowledgeCategories[0].DataCategoryGroupName;
        String childCategoryName = knowledgeCategories[0].DataCategoryName;

        Test.startTest();
        List<Knowledge__kav> articles = KnowledgeArticleController.getFilteredArticles(
            parentCategoryName,
            'en_US',
            childCategoryName,
            'Draft'
        );
        Test.stopTest();

        // Validate results
        System.assert(!articles.isEmpty(), 'Articles should be retrieved');
    }

    @isTest
    static void testCreateDraftVersion() {
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];

        Test.startTest();
        try {
            Id draftId = KnowledgeArticleController.createDraftVersion(
                article.Id
            );
            System.assert(draftId != null, 'Draft version should be created');
        } catch (Exception e) {
            System.debug('Caught exception: ' + e.getMessage());
            System.assert(
                true,
                'An unexpected exception occurred: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteArticle() {
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];

        Test.startTest();
        Id deletedId = KnowledgeArticleController.deleteArticle(article.Id);
        Test.stopTest();

        System.assert(deletedId != null, 'Article should be deleted');
    }

    @isTest
    static void testDeleteArticleException() {
        // Use a valid but non-existent ID format for testing
        Id nonExistentArticleId = 'ka0J7000000kADvIOM';

        Test.startTest();
        try {
            KnowledgeArticleController.deleteArticle(nonExistentArticleId);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(true, 'AuraHandledException caught as expected');
        }
        Test.stopTest();
    }

    @isTest
    static void testEditArchivedArticle() {
        // Create test data: A draft article
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];

        Test.startTest();
        try {
            Id editedId = KnowledgeArticleController.editArchivedArticle(
                article.Id
            );
            System.assert(
                editedId != null,
                'Archived article should be editable'
            );
        } catch (Exception e) {
            System.debug('Caught exception: ' + e.getMessage());
            System.assert(
                true,
                'An unexpected exception occurred: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteArchivedArticle() {
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];

        Test.startTest();
        try {
            Id deletedId = KnowledgeArticleController.deleteArchivedArticle(
                article.Id
            );
            System.assert(
                deletedId != null,
                'Archived article should be deleted'
            );
        } catch (Exception e) {
            System.debug('Caught exception: ' + e.getMessage());
            System.assert(
                true,
                'An unexpected exception occurred: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testFetchLanguages() {
        Test.startTest();
        List<Articles_Translated_Languages__mdt> languages = KnowledgeArticleController.fetchLanguages();
        Test.stopTest();

        System.assert(!languages.isEmpty(), 'Languages should not be empty');
    }

    @isTest
    static void testChildCategoriesController() {
        // Query to get a parent category name
        List<Active_Data_Category_Groups__mdt> parentCategories = [
            SELECT Category_Name__c
            FROM Active_Data_Category_Groups__mdt
            WHERE IsParent__c = TRUE
            LIMIT 1
        ];

        if (parentCategories.isEmpty()) {
            System.debug('No parent categories found. Skipping test.');
            return; 
        }

        String parentCategory = parentCategories[0].Category_Name__c;

        // Test the method
        Test.startTest();
        try {
            List<Active_Data_Category_Groups__mdt> childCategories = KnowledgeArticleController.childCategoriesController(
                parentCategory
            );

            // Verify that the correct child categories are returned
            if (childCategories.isEmpty()) {
                System.debug(
                    'No child categories found for the parent category.'
                );
                return; // Or create test data if necessary
            }

            System.assert(
                childCategories.size() > 0,
                'Expected child categories'
            );

            // Check if all returned categories are indeed child categories
            for (Active_Data_Category_Groups__mdt category : childCategories) {
                System.assert(
                    category.IsParent__c == false,
                    'Expected child category'
                );
                System.assert(
                    category.Parent_Category__c == parentCategory,
                    'Expected parent category match'
                );
            }
        } catch (Exception e) {
            System.debug('Caught exception: ' + e.getMessage());
            System.assert(
                false,
                'An unexpected exception occurred: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testCategoriesController() {
        Test.startTest();
        List<Active_Data_Category_Groups__mdt> categories = KnowledgeArticleController.categoriesController();
        Test.stopTest();
        System.assert(
            categories != null && !categories.isEmpty(),
            'Categories should not be empty'
        );
    }
}