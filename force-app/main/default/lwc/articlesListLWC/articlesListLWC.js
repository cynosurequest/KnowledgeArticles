import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFilteredArticles from '@salesforce/apex/KnowledgeArticleController.getFilteredArticles';
import createDraftVersion from '@salesforce/apex/KnowledgeArticleController.createDraftVersion';
import editArchivedArticle from '@salesforce/apex/KnowledgeArticleController.editArchivedArticle';
import deleteArticle from '@salesforce/apex/KnowledgeArticleController.deleteArticle';
import deleteArchivedArticle from '@salesforce/apex/KnowledgeArticleController.deleteArchivedArticle';

export default class ArticlesListLWC extends NavigationMixin(LightningElement) {
    @api label;
    @api child;
    @api status;
    @api language;
    @track articles = [];
    @wire(getFilteredArticles, {
        parentDataCategory: '$label',
        language: '$language',
        category: '$child',
        status: '$status'
    }) wiredArticles;

    connectedCallback() {
        this.wiredArticles;
        console.log('Connected callback executed');
        this.refreshData();
        this.startPolling();
    }

    startPolling() {
        console.log('Polling started');
        setInterval(() => {
            this.refreshData();
        }, 10000); 
    }

    refreshData() {
        return refreshApex(this.wiredArticles).then(() => {
            console.log('Data refreshed');
        });
    }

    get processedArticles() {
        console.log('Processing articles...');
        if (!this.wiredArticles.data) return [];
        const processed = this.wiredArticles.data.map(article => ({
            Id: article.Id,
            Title: article.Title,
            Status: article.PublishStatus,
            showDeleteButton: article.PublishStatus === 'Draft' || article.PublishStatus === 'Archived'
        }));
        processed.push({ Id: 'createTile', isCreateTile: true });
        console.log('Processed articles:', processed);

        return processed;
    }

    handleEditClick(event) {
        const articleId = event.currentTarget.dataset.id;
        if (this.status === 'Published') {
            createDraftVersion({ articleId })
                .then(draftId => {
                    const recordUrl = `/lightning/r/Knowledge__kav/${draftId}/view`;
                    window.open(recordUrl, '_blank');
                })
                .catch(error => {
                    console.error('Error creating draft version:', error);
                    this.showToast('Error', 'Error creating draft version: ' + error.body.message, 'error');
                });
        } else if (this.status === 'Draft') {
            this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                    recordId: articleId,
                    actionName: 'edit'
                    }
                    });
            // const recordUrl = `/lightning/r/Knowledge__kav/${articleId}/edit`;
            // console.log(recordUrl);
            // window.open(recordUrl, '_blank');
        } else if (this.status === 'Archived') {
            editArchivedArticle({ articleId })
                .then(archivedEdit => {
                    const recordUrl = `/lightning/r/Knowledge__kav/${archivedEdit}/view`;
                    window.open(recordUrl, '_blank');
                })
                .catch(error => {
                    console.error('Error editing Archived article:', error);
                    this.showToast('Error', 'Error editing the article: ' + error.body.message, 'error');
                });
        }
    }

    handleViewClick(event) {
        const articleId = event.currentTarget.dataset.id;
        const recordUrl = `/lightning/r/Knowledge__kav/${articleId}/view`;
        window.open(recordUrl, '_blank');
    }

    handleDeleteClick(event) {
        const articleId = event.currentTarget.dataset.id;
        if (this.status === 'Published' || this.status === 'Draft') {
            deleteArticle({ articleId })
                .then(() => {
                    this.showToast('Success', 'Article deleted successfully.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting article:', error);
                    this.showToast('Error', 'Error deleting the article: ' + error.body.message, 'error');
                });
        } else if (this.status === 'Archived') {
            deleteArchivedArticle({ articleId })
                .then(() => {
                    this.showToast('Success', 'Article deleted successfully.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting archived article:', error);
                    this.showToast('Error', 'Error deleting the article: ' + error.body.message, 'error');
                });
        }
    }

    handleCreateClick() {
        console.log('label ' + this.label);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Knowledge__kav',
                actionName: 'new'
            }
            // state: {                                                     // If needed we could assign other language  
            //     defaultFieldValues: `Language=${this.language}`          
            // }
        });
        console.log('attributes ' +this.attributes );
        console.log('defaultFieldValues ' +this.defaultFieldValues );
    }

    refreshData() {
        return refreshApex(this.wiredArticles).then(() => {
            console.log('Data refreshed');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}