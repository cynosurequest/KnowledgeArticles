public class TestDataFactory {
    public static Knowledge__kav createKnowledgeArticle(String urlName, String title, String language) {
        return new Knowledge__kav(
            UrlName = urlName,
            Title = title,
            Language = language
        );
    }

    public static Knowledge__DataCategorySelection createDataCategorySelection(Id parentId, String groupName, String categoryName) {
        return new Knowledge__DataCategorySelection(
            ParentId = parentId,
            DataCategoryGroupName = groupName,
            DataCategoryName = categoryName
        );
    }
}