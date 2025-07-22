import { LightningElement, api } from 'lwc';
import generateC360Summary from '@salesforce/apex/C360PromptService.generateC360Summary';
import getContactRelatedRecords from '@salesforce/apex/C360PromptService.getContactRelatedRecords';


export default class C360Summary extends LightningElement {
    @api customerName;
    textSummary;
    dataSummary;
    error;
    isLoading = false;

    renderedCallback() {
    if (this.textSummary) {
        this.animateText('customer', this.textSummary.customerSection);
        this.animateText('account', this.textSummary.accountSection);
    }
}
animateText(type, htmlString) {
    const target = this.template.querySelector(`div.animate-target[data-type="${type}"]`);
    if (!target || !htmlString) return;

    // temp DOM으로 HTML 파싱
    const temp = document.createElement('div');
    temp.innerHTML = htmlString;
    const nodes = Array.from(temp.childNodes);

    target.innerHTML = '';
    let i = 0;

    const renderNext = () => {
        if (i >= nodes.length) return;

        const node = nodes[i];
        if (node.nodeType === Node.TEXT_NODE) {
            const span = document.createElement('span');
            target.appendChild(span);
            let j = 0;
            const interval = setInterval(() => {
                if (j < node.textContent.length) {
                    span.textContent += node.textContent.charAt(j++);
                } else {
                    clearInterval(interval);
                    i++;
                    renderNext();
                }
            }, 20);
        } else {
            target.appendChild(node.cloneNode(true));
            i++;
            renderNext();
        }
    };

    renderNext();
}


    connectedCallback() {
        this.fetchAll();
    }

    async fetchAll() {
        this.isLoading = true;
        this.error = null;

        try {
            const [text, data] = await Promise.all([
                generateC360Summary({ formattedName: this.customerName }),
                getContactRelatedRecords({ formattedName: this.customerName })
            ]);

            this.textSummary = text;
            this.dataSummary = data;

            // 애니메이션 효과 적용
            this.startTyping('customer', text.customerSection);
            this.startTyping('account', text.accountSection);
        } catch (e) {
            this.error = '잠시만 기다려 주세요. 로딩중..';
            console.error(e);
        } finally {
            this.isLoading = false;
        }
    }

    startTyping(type, text) {
        const container = this.template.querySelector(`div[data-type="${type}"]`);
        if (!container || !text) return;

        container.innerHTML = ''; // 초기화
        let index = 0;
        const chars = text.split('');
        const timer = setInterval(() => {
            container.innerHTML += chars[index];
            index++;
            if (index >= chars.length) {
                clearInterval(timer);
            }
        }, 15); // 속도 조절
    }

    onCaseClicked(event) {
        const id = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('caseclick', { detail: id }));
    }

    onAssetClicked(event) {
        const id = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('assetclick', { detail: id }));
    }
}
