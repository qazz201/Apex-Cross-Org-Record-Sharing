import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import {
    showToastNotification,
    ERROR_TITLE,
    ERROR_VARIANT,
    SUCCESS_VARIANT
} from "c/toastMessage";
import {isEmptyString, isEmptyArray} from 'c/commons';
import {fireEvent} from 'c/pubsub';

//Apex
import tryToAuthorize from '@salesforce/apex/AuthenticationController.authorize';

//Labels
import authenticationSuccessful from '@salesforce/label/c.Auth_Lbl_AuthenticationSuccessful';
import authenticate from '@salesforce/label/c.Auth_Lbl_Authenticate';

const AUTH_CODE = 'code';
const AUTH_EVENT = 'authenticate';
const AUTHORIZATION_PATH = 'services/oauth2/authorize';

export default class Authentication extends LightningElement {
    @wire(CurrentPageReference) pageRef; // Required by pubsub
    @api clientId = '';
    @api clientSecret = '';
    @api callbackUrl = '';
    @api environmentUrl = ''; // production or sandbox

    authCode = ''; //extracted from url
    authWindow;
    intervalIds = [];
    defaultAuthEventDetail = {success: false};
    labels = {authenticationSuccessful, authenticate};

    disconnectedCallback() {
        if (isEmptyArray(this.intervalIds)) return;
        this.clearIntervals();
    }

    openAuthWindow() {
        try {
            this.authWindow = window.open(this.authorizationUrl, "MsgWindow", "width=500,height=500,left=500");
            this.trackWindowLocationChange();
            this.trackWindowClose();
        } catch (error) {
            console.error(error.stack);
            showToastNotification(ERROR_TITLE, error, ERROR_VARIANT);
        }
    }

    clearIntervals() {
        this.intervalIds.forEach(interval => clearInterval(interval));
        this.intervalIds = [];
    }

    handleAuthWindowClose = () => {
        this.clearIntervals();

        if (!this.authCode || isEmptyString(this.authCode)) {
            this.handleFailedAuthentication();
            return;
        }

        this.handleSuccessfulAuthentication();
    }

    handleSuccessfulAuthentication() {
        tryToAuthorize({
            authCode: this.authCode,
            clientId: this.clientId,
            clientSecret: this.clientSecret,
            callbackUrl: this.callbackUrl,
            environmentUrl: this.environmentUrl,
        }).then(() => {
            console.log('Connected app data saved!')
            const eventParams = {...this.defaultAuthEventDetail, success: true};

            fireEvent(this.pageRef, AUTH_EVENT, eventParams);
            this.dispatchAuthorizationEvent(eventParams);
            showToastNotification(this.labels?.authenticationSuccessful, {}, SUCCESS_VARIANT);
        }).catch(error => {
            this.handleFailedAuthentication(error);
        })
    }

    handleFailedAuthentication(error = {}) {
        console.error('Failed Authentication error: ', JSON.stringify(error));

        this.dispatchAuthorizationEvent(this.defaultAuthEventDetail);
        fireEvent(this.pageRef, AUTH_EVENT, this.defaultAuthEventDetail);
        error && showToastNotification(ERROR_TITLE, error, ERROR_VARIANT);
    }

    handleChangeWindowLocation(urlSearchParams = '') {
        this.authWindow.close();
        this.getAuthCodeFromUrl(urlSearchParams);
        this.handleAuthWindowClose();
    }

    getAuthCodeFromUrl(searchLink = '') {
        const searchParams = new URLSearchParams(searchLink);
        if (!searchParams.has(AUTH_CODE)) return;

        this.authCode = searchParams.get(AUTH_CODE);
        return this.authCode;
    }

    dispatchAuthorizationEvent(detail = {}) {
        this.dispatchEvent(new CustomEvent(AUTH_EVENT, {detail}));
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

    validateEnvironmentUrl() {
        if (this.environmentUrl.endsWith('/')) return;
        this.environmentUrl = `${this.environmentUrl}/`;
    }

    get authorizationUrl() {
        if (!this.canAuthUrlBeGenerated) {
            const errorMsg = `Please give the next information: Environment URL,Client Id,Callback URL.
             Your values are: Environment URL- ${this.environmentUrl}, Client Id- ${this.clientId}, Callback URL- ${this.callbackUrl}`;
            throw new Error(errorMsg);
            // todo: SHOW TOAST ERROR
        }

        this.validateEnvironmentUrl();
        return `${this.environmentUrl}${AUTHORIZATION_PATH}?client_id=${this.clientId}&response_type=code&redirect_uri=${this.callbackUrl}`;
    }

    get canAuthUrlBeGenerated() {
        return !isEmptyString(this.environmentUrl)
            & !isEmptyString(this.clientId)
            & !isEmptyString(this.callbackUrl);
    }
}