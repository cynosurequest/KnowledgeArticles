/**
 * KnowledgeArticleController Apex Class
 *
 * This class provides methods to fetch, create, edit, and delete Knowledge Articles.
 * It also includes methods to retrieve active data categories and translated languages.
 *
 * Key Functionalities:
 * - Fetch filtered Knowledge Articles based on category, language, and status.
 * - Create a draft version of an article.
 * - Delete an article or archived article.
 * - Edit an archived article.
 * - Retrieve available article languages and active data categories.
 *
 * Author: Pragadish Nandha S
 * Created Date: 03-03-2025
 */
public with sharing class KnowledgeArticleController {
     /**
      * Retrieves filtered Knowledge articles based on given parameters.
      * @param parentDataCategory - The parent data category of the article.
      * @param language - The language of the article.
      * @param category - The specific category within the parent category.
      * @param status - The status of the article (Published, Draft, Archived).
      * @return List of Knowledge__kav articles matching the criteria.
      */
     @AuraEnabled(cacheable=true)
     public static List<Knowledge__kav> getFilteredArticles(
          String parentDataCategory,
          String language,
          String category,
          String status
     ) {
          // System.debug('parentDataCategory'+parentDataCategory);
          // System.debug('language'+language);
          // System.debug('category'+category);
          // System.debug('status'+status);
          // System.debug('Hi'+language);
          String statusValue;

          if (status == 'Published') {
               statusValue = 'Online';
          } else if (status == 'Draft') {
               statusValue = 'Draft';
          } else if (status == 'Archived') {
               statusValue = 'Archived';
          } else {
               statusValue = 'Online';
          }

          Knowledge__kav article = new Knowledge__kav(Language = language);

          String categoryFormatted = category.replace(' ', '_') + '__c';
          System.debug('categoryFormatted ' + categoryFormatted);
          String parentCategoryFormatted =
               parentDataCategory.replace(' ', '_') + '__c';
          System.debug('parentCategoryFormatted ' + parentCategoryFormatted);
          String query =
               'SELECT Id, Title, Answer__c, Question__c, PublishStatus ' +
               'FROM Knowledge__kav ' +
               'WHERE PublishStatus = \'' +
               statusValue +
               '\' ' +
               'AND Language = \'' +
               language +
               '\' ' +
               'WITH DATA CATEGORY ' +
               parentCategoryFormatted +
               ' AT (' +
               categoryFormatted +
               ')';
          System.debug(query);

          // Execute the query
          List<Knowledge__kav> articles = Database.query(query);

          System.debug('Articles Retrieved: ' + articles);

          return articles;
     }

     /**
      * Creates a draft version of a published Knowledge article.
      * @param articleId - The ID of the existing article.
      * @return ID of the draft version created.
      */
     // @AuraEnabled
     // public static Id createDraftVersion(Id articleId) {
     //      try {
     //           Knowledge__kav article = [
     //                SELECT Id, KnowledgeArticleId
     //                FROM Knowledge__kav
     //                WHERE Id = :articleId
     //                LIMIT 1
     //           ];
     //           return KbManagement.PublishingService.editOnlineArticle(
     //                article.KnowledgeArticleId,
     //                true
     //           );
     //      } catch (Exception e) {
     //           throw new AuraHandledException(
     //                'Error creating draft version: ' + e.getMessage()
     //           );
     //      }
     // }

// @AuraEnabled
// public static Id createDraftVersion(Id articleId) {
//     try {
//         Knowledge__kav article = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articleId LIMIT 1];

//         if (article == null) {
//             throw new AuraHandledException('Article not found with Id: ' + articleId);
//         }

//         String idStr = KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, true);
//         System.debug('Id : ' + idStr);

//         // Assuming idStr is a valid Id string
//         return Id.valueOf(idStr);
//     } catch (Exception e) {
//         System.debug('Caught exception: ' + e.getMessage());
//         throw new AuraHandledException('Error creating draft version: ' + e.getMessage());
//     }
// }
    @AuraEnabled
    public static Id createDraftVersion(Id articleId) {
        try {
            Knowledge__kav article = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav where Id = :articleId LIMIT 1];

            String id = KbManagement.PublishingService.editOnlineArticle (article.KnowledgeArticleId, true);
            System.debug('Id : '+id);

            return Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating draft version: ' + e.getMessage());
        }
    }



     /**
      * Deletes a draft Knowledge article.
      * @param articleId - The ID of the article to be deleted.
      * @return ID of the deleted article.
      */
     @AuraEnabled
     public static Id deleteArticle(Id articleId) {
          try {
               Knowledge__kav articleToDelete = [
                    SELECT Id, KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Id = :articleId
                    LIMIT 1
               ];
               KbManagement.PublishingService.deleteDraftArticle(
                    articleToDelete.KnowledgeArticleId
               );
               return articleToDelete.KnowledgeArticleId;
          } catch (Exception e) {
               throw new AuraHandledException(
                    'Error deleting the article: ' + e.getMessage()
               );
          }
     }

     /**
      * Edits an archived Knowledge article.
      * @param articleId - The ID of the archived article.
      * @return ID of the edited archived article.
      */
     @AuraEnabled
     public static Id editArchivedArticle(Id articleId) {
          try {
               Knowledge__kav archivedArticleToEdit = [
                    SELECT Id, KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Id = :articleId
                    LIMIT 1 
               ];
               return KbManagement.PublishingService.editArchivedArticle(
                    archivedArticleToEdit.KnowledgeArticleId
               );
          } catch (Exception e) {
               throw new AuraHandledException(
                    'Error editing the archived article: ' + e.getMessage()
               );
          }
     }

     /**
      * Deletes an archived Knowledge article.
      * @param articleId - The ID of the archived article to be deleted.
      * @return ID of the deleted archived article.
      */
     @AuraEnabled
     public static Id deleteArchivedArticle(Id articleId) {
          try {
               Knowledge__kav archivedArticleToDelete = [
                    SELECT Id, KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Id = :articleId
                    LIMIT 1
               ];
               KbManagement.PublishingService.deleteArchivedArticle(
                    archivedArticleToDelete.KnowledgeArticleId
               );
               return archivedArticleToDelete.KnowledgeArticleId;
          } catch (Exception e) {
               throw new AuraHandledException(
                    'Error deleting the archived article: ' + e.getMessage()
               );
          }
     }

     /**
      * Retrieves all available translated article languages from metadata.
      * @return List of Articles_Translated_Languages__mdt records.
      */
     @AuraEnabled(cacheable=true)
     public static List<Articles_Translated_Languages__mdt> fetchLanguages() {
          System.debug(Articles_Translated_Languages__mdt.getAll().values());
          return Articles_Translated_Languages__mdt.getAll().values();
     }

     /**
      * Retrieves all active data category groups from metadata.
      * @return List of Active_Data_Category_Groups__mdt records.
      */
     @AuraEnabled(cacheable=true)
     public static List<Active_Data_Category_Groups__mdt> categoriesController() {
          Set<String> uniqueCategories = new Set<String>();
          List<Active_Data_Category_Groups__mdt> uniqueMetadata = new List<Active_Data_Category_Groups__mdt>();

          for (
               Active_Data_Category_Groups__mdt category : Active_Data_Category_Groups__mdt.getAll()
                    .values()
          ) {
               if (
                    !uniqueCategories.contains(category.Parent_Category__c) &&
                    category.isParent__c == true
               ) {
                    uniqueCategories.add(category.Parent_Category__c);
                    uniqueMetadata.add(category);
               }
          }
          return uniqueMetadata;
     }

     /**
      * Retrieves child categories based on a given parent category.
      * @param parentCategory - The parent category name.
      * @return List of Active_Data_Category_Groups__mdt child category records.
      */
     @AuraEnabled(cacheable=true)
     public static List<Active_Data_Category_Groups__mdt> childCategoriesController(
          String parentCategory
     ) {
          return [
               SELECT Category_Name__c ,Parent_Category__c, IsParent__c
               FROM Active_Data_Category_Groups__mdt
               WHERE Parent_Category__c = :parentCategory AND IsParent__c = FALSE
          ];
     }
}