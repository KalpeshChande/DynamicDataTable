import { LightningElement, track, api } from 'lwc';

export default class DatatableTextarea extends LightningElement {
    @api value;
    @api fieldName;
    @api context;
    @track showTextarea = false;

    /**
     * Handles the change event when the textarea value is modified.
     * @param {Event} event - The change event.
     */
    handleChange(event) {
        //show the selected value on UI
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.value = event.target.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(
            new CustomEvent('textareachanged', {
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

        this.closeTextarea();
    }

    /**
     * Description
     * Shows the textarea for editing.
     *  @returns {any}
     */
    editTextarea() {
        this.showTextarea = true;
    }

    /**
     * Description
     * Closes the textarea.
     * @returns {any}
     */
    closeTextarea() {
        this.showTextarea = false;
    }
}