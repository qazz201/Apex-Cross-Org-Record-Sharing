import {LightningElement, api} from 'lwc';
import {isEmptyString, isEmptyArray} from "c/commons";

const AUTH_CODE = 'code';
const AUTHORIZE_EVENT = 'authorize';

export default class Authorization extends LightningElement {
    @api authUrl = 'https://login.salesforce.com/services/oauth2/authorize?client_id=3MVG9vvlaB0y1YsLh_esB2JsdW3kCVkDIysPgrk0VxVRnEXx2YP2afWYeLwAyax21ZXpnuDSja78PyoY6zcHx&response_type=code&redirect_uri=https://empathetic-shark-ve6ud3-dev-ed.trailblaze.lightning.force.com/lightning/n/Share_records';
    @api authCode = '';

    authWindow;
    intervalIds = [];
    defaultAuthorizationEventDetail = {success: false}

    disconnectedCallback() {
        if (isEmptyArray(this.intervalIds)) return;
        this.clearIntervals();
    }

    openAuthWindow() {
        this.authWindow = window.open(this.authUrl, "MsgWindow", "width=500,height=500,left=500");
        this.trackWindowLocationChange();
        this.trackWindowClose();
    }

    clearIntervals() {
        this.intervalIds.forEach(interval => clearInterval(interval));
        this.intervalIds = [];
    }

    handleAuthWindowClose = () => {
        this.clearIntervals();

        if (isEmptyString(this.authCode)) {
            this.dispatchAuthorizationEvent(this.defaultAuthorizationEventDetail);
            return;
        }

        this.dispatchAuthorizationEvent({...this.defaultAuthorizationEventDetail, success: true});
    }

    handleChangeWindowLocation(urlSearchParams = '') {
        this.authWindow.close();
        this.getAuthCodeFromUrl(urlSearchParams);
        this.handleAuthWindowClose();
        console.log(this.authCode, 'AUTH CODE')
    }

    getAuthCodeFromUrl(searchLink = '') {
        const searchParams = new URLSearchParams(searchLink);
        if (!searchParams.has(AUTH_CODE)) return;

        this.authCode = searchParams.get(AUTH_CODE);
        return this.authCode;
    }

    dispatchAuthorizationEvent(detail = {}) {
        this.dispatchEvent(new CustomEvent(AUTHORIZE_EVENT, {detail}));
    }

    trackWindowLocationChange() {
        this.intervalIds.push(
            setInterval(() => {
                const searchParams = this.authWindow.location.search;
                if (searchParams) {
                    this.handleChangeWindowLocation(searchParams);
                }
            }, 100)
        );
    }

    trackWindowClose() {
        this.intervalIds.push(
            setInterval(() => {
                if (this.authWindow.closed) {
                    this.handleAuthWindowClose();
                }
            }, 1000)
        );
    }
}