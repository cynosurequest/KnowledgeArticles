import { LightningElement , api } from 'lwc';
export default class ActiveSubCategories extends LightningElement {
    @api label;
    @api receivedCategory;
    
    selectedChildCategory;

    isShowLanguages = true;
    isPrimaryModal = false;
    isShowModal = false;
    isShowModalSecond = false ;
    selectedStatus;
    selectedLanguage = 'en_US';
    
    categoryNames = [];

    get modalHeader() {
        if (this.isShowLanguages) {
            console.log('Testmodal1');
            return 'Choose your Preferred Language';
        } else if (this.isShowModal) {
            console.log('Testmodal2');
            return 'Choose your Preferred Status';
        } else if (this.isShowModalSecond) {
            console.log('Testmodal3');
            return 'Articles';
        }
        return ''; // Default header if none match
    }

    navigateToDetailsPage(event) {
        console.log('label '+this.label);
        const childCategory = event.target.dataset.child;
        console.log('Child Category '+childCategory);
        this.selectedChildCategory = childCategory;
        this.isPrimaryModal = true;     
        this.isShowModal = false;
        this.isShowLanguages = true;
        console.log('As expected Child category is fetched '+this.selectedChildCategory);

    }



    hideModalBoxCancel() {
        this.isShowModal = false;
        this.isPrimaryModal = false;
        this.isShowModal = false;
        this.isShowModalSecond = false ;
        
    }
    handleCustomEvent(event){
        this.isPrimaryModal = true ;
        this.isShowModal = true;
        this.selectedStatus = event.detail;
        this.isShowModal = false;
        this.isShowModalSecond = true ;
    }
    handleHomeClick(){
        this.isShowModalSecond = false;
        this.isShowModal = false;
    }

    onHandleNextStatus(){
        this.isShowLanguages = false;
        this.isShowModal = true; 
    }

    onHandleBackStatus(){
        this.isShowModalFirst = true;
        this.isShowModal = false; 
        this.isShowLanguages = true;
    }

    onHandleBack(){
        this.isShowModal = true;
        this.isShowModalSecond = false ;
    }

    handleLanguage(event){
        console.log('event'+JSON.stringify(event.detail));   
        this.selectedLanguage =  event.detail
    }

}