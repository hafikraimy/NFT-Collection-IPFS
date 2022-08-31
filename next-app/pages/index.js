import Head from 'next/head';
import styles from '../styles/Home.module.css';
import React, { useState, useEffect, useRef } from 'react';
import { providers, Contract, utils } from 'ethers';
import Web3Modal from 'web3modal';
import { abi, NFT_CONTRACT_ADDRESS } from '../constants';


export default function Home() {
  const [tokenIdsMinted, setTokenIdsMinted] = useState("0");
  const [walletConnected, setWalletConnected] = useState(false);
  const [loading, setLoading] = useState(false);
  const web3ModalRef = useRef();

  const publicMint = async () => {
    try {
      console.log("Public mint");
      // we need a signer since this is a write transaction
      const signer = await getProviderOrSigner(true);
      const nftContract = new Contract(NFT_CONTRACT_ADDRESS, abi, signer);
      // call the mint function from the contract
      const tx = await nftContract.mint({
        value: utils.parseEther("0.01")
      })
      setLoading(true);
      await tx.wait();
      setLoading(false);
      window.alert("You successfully minted a LW3Punk!")
    } catch (error) {
      console.error(error);
    }
  }

  const getTokenIdsMinted = async () => {
    try {
      const provider = await getProviderOrSigner();
      const nftContract = new Contract(NFT_CONTRACT_ADDRESS, abi, provider);

      const _tokenIds = await nftContract.tokenIds();
      console.log("tokenIds", _tokenIds);
      // tokenIds is a BigNumber. need to convert the BigNumber to a string 
      setTokenIdsMinted(_tokenIds.toString());
    } catch (error) {
      console.error(error);
    }
  }

  const getProviderOrSigner = async (needSigner = false) => {
    try {
      const provider = await web3ModalRef.current.connect();
      const web3Provider = new providers.Web3Provider(provider);
      
      const { chainId } = await web3Provider.getNetwork();
      if(chainId != 80001){
        window.alert("Change the nertwork to Mumbai");
        throw new Error("Change the network to Mumbai");
      }

      if(needSigner) {
        const signer = await web3Provider.getSigner();
        return signer;
      }
      return web3Provider;
    } catch (error) {
      console.error(error);
    }
  }

  const connectWallet = async () => {
    try {
      await getProviderOrSigner(true);
      setWalletConnected(true);
    } catch (error) {
      console.error(error);
    }
  }

  useEffect(() => {
    if(!walletConnected){
      web3ModalRef.current = new Web3Modal({
        network: "mumbai",
        providerOptions: {},
        disableInjectedProvider: false,
      });
      connectWallet();
      getTokenIdsMinted();

      setInterval(async () => {
        await getTokenIdsMinted();
      }, 5 * 1000)

    }
  }, [walletConnected])

  const renderButton = () => {
    if(!walletConnected){
      return (
        <button className={styles.button} onClick={connectWallet}>Connect Wallet</button>
      );
    } 

    if(loading){
      return <button className={styles.button}>Loading...</button>;
    }

    return (
      <button className={styles.button} onClick={publicMint}>
        Public Mint 🚀
      </button>
    );
    
  }

  return (
   <div>
      <Head>
        <title>LW3Punks</title>
        <meta name="description" content="LW3Punks-Dapp" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className={styles.main}>
        <div>
          <h1 className={styles.title}>Welcome to LW3Punks!</h1>
          <div className={styles.description}>
            Its an NFT Collection for LearnWeb3 students.
          </div>
          <div className={styles.description}>
            {tokenIdsMinted}/10 have been minted
          </div>
          {renderButton()}
        </div>
        <div>
          <img className={styles.image} src="./LW3Punks/1.png" />
        </div>
      </div>
        <footer className={styles.footer}>
          Made with &#10084; by hafikraimy
        </footer>
   </div>
  )
}
