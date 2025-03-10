import {LightningElement , wire} from 'lwc';
import categoriesController from '@salesforce/apex/KnowledgeArticleController.categoriesController';
import childCategoriesController from '@salesforce/apex/KnowledgeArticleController.childCategoriesController';

export default class ActiveDataCategories extends LightningElement {
  selectedDataCategory = '';
  categoryOptions = [];
  categoryNames = [];


  @wire(categoriesController)
  getCategories({error,data}) {
    if (data) {
      console.log('data => ', JSON.stringify(data));
      this.categoryOptions = data.map(category => ({
        Id: category.Id,
        label: category.Parent_Category__c,
        isSelected: false, // Add `isSelected` flag to track state
        className: 'slds-tile slds-tile_board slds-m-around_small grey-background tile-title'
      }));
      console.log('Category options: ', JSON.stringify(this.categoryOptions));
    } else if (error) {
      console.error('Error fetching categories: ', error);
    }
  }

  handleCategoryClick(event) {
    const selectedLabel = event.target.dataset.label;
    this.categoryOptions = this.categoryOptions.map(category => {
      const isSelected = category.label === selectedLabel;
      const className = isSelected ?
        'slds-tile slds-tile_board slds-m-around_small selected-category white-text tile-title' :
        'slds-tile slds-tile_board slds-m-around_small grey-background tile-title';
      console.log(`Category ${category.label}: className = ${className}`);

      return {
        ...category,
        isSelected: isSelected,
        className: className
      };
    });


    this.selectedDataCategory = selectedLabel;

    // Fetch child categories for the selected parent category
    childCategoriesController({
        parentCategory: this.selectedDataCategory
      })
      .then(result => {
        this.categoryNames = result.map(item => item.Category_Name__c);
        console.log('Sub Category Names : '+this.categoryNames);
      })
      .catch(error => {
        console.error('Error fetching child categories: ', error);
      });
  }
}