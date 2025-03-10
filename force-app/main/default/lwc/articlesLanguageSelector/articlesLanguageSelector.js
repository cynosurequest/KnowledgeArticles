import { LightningElement , wire } from 'lwc';
import fetchLanguages from '@salesforce/apex/KnowledgeArticleController.fetchLanguages';


export default class ArticlesLanguageSelector extends LightningElement {

    selectedLanguage = '';
    selectedLanguageLabel ='';
    languageOptions = [];

    @wire(fetchLanguages)
    getLanguages({ error, data }){
        if(data){
            console.log('data => ', JSON.stringify(data));
            this.languageOptions = data.map(language => ({
                label: language.Languages__c,
                value: language.Language_Code__c
            }));
        }
        if (this.languageOptions.length > 0) {
            this.selectedLanguage = this.languageOptions[0].value;
        }
        else if(error){
            console.log('Error' + error);
        }
    }

    handleLanguageChange(event) {
        this.selectedLanguage = event.detail.value;
        console.log('Choosen language'+this.selectedLanguage);
        this.dispatchEvent(new CustomEvent('languagecustomevent', { detail: this.selectedLanguage}));
        
    }
 

    
}