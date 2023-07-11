import { LightningElement, track, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {
    @api options;
    @api value;
    @api fieldName;
    @api context;
    @track showPicklist = false;

    /**
     * Description
     * Handles the change event when the picklist value is modified.
     * @param {Event} event - The change event.
     */
    handleChange(event) {
        //show the selected value on UI
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.value = event.detail.value;

        //fire event to send context and selected value to the data table
        this.dispatchEvent(
            new CustomEvent('picklistchanged', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    data: {
                        context: this.context,
                        fieldName: this.fieldName,
                        value: this.value
                    }
                }
            })
        );

        this.closePicklist();
    }

    /**
     * Description
     *  Shows the picklist for editing.
     * @returns {any}
     */
    editPicklist() {
        this.showPicklist = true;
    }

    /**
     * Description
     * Closes the picklist.
     * @returns {any}
     */
    closePicklist() {
        this.showPicklist = false;
    }
}