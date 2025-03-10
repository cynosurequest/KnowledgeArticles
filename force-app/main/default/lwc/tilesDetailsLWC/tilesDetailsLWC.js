import { LightningElement, api} from 'lwc';
export default class TilesDetailsLWC extends LightningElement {
    @api label;
    @api child;
    selectedStatus = ''; 
    isShowModal = false; 
    handleStatusClick(event) {
        this.selectedStatus = event.target.dataset.status;
        console.log('Status'+this.selectedStatus);
        this.isShowModal = true;
        this.dispatchEvent(new CustomEvent('articlescustomevent', { detail: this.selectedStatus }));
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
    navigateToHome() {
        window.location.reload();
    }
    
}