<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PropServiceWork._Default" %>


<asp:Content ID="script" ContentPlaceHolderID="javaScript" runat="server">
<script>

    var chave = urlBase64ToUint8Array("BIKBrKS5h0pQROCWb8M_BLSIV5URJGITnv8BPaddI8WIkPfcBcN1JP5OTWcUh96WSawTGbXzYis3JfMBhzYSnlM");

    console.log(chave);

    if ('PushManager' in window) {
        console.log("Push API é suportado.");
    } else {
        console.error("Push API não é suportado neste navegador.");
    }

    navigator.serviceWorker.register("/ServiceWorker.js")
        .then((reg) => {
            if (reg.active) {
                console.log("Service Worker está ativo.");
            } else {
                console.error("Service Worker não está ativo.");
            }
        })
        .catch((err) => {
            console.error("Erro ao registrar o Service Worker:", err);
        });

    navigator.serviceWorker.register("/ServiceWorker.js", { scope: "/" })
        .then((reg) => {
            console.log("Service Worker registrado com escopo:", reg.scope);
        });
        
    if ('serviceWorker' in navigator) {
        window.addEventListener("load", () => {
            navigator.serviceWorker.register("/ServiceWorker.js")
                .then((reg) => {
                    if (Notification.permission === "granted") {
                        getSubscription(reg);
                    } else if (Notification.permission === "blocked") {
                        $("#NoSupport").show();
                    } else {
                        $("#GiveAccess").show();
                        requestNotificationAccess(reg);
                    }
                });
        });
    } else {
        $("#NoSupport").show();
    }

    function requestNotificationAccess(reg) {
        Notification.requestPermission(function (status) {
            $("#GiveAccess").hide();
            if (status == "granted") {
                getSubscription(reg);
            } else {
                $("#NoSupport").show();
            }
        });
    }

    function getSubscription(reg) {
        
        reg.pushManager.getSubscription().then(function (sub) {
            if (sub === null) {
                reg.pushManager.subscribe({
                    userVisibleOnly: true,
                    applicationServerKey: chave
                }).then(function (sub) {
                    fillSubscribeFields(sub);
                }).catch(function (e) {
                    console.error("Não é possível assinar o push", e);
                });
            } else {
                fillSubscribeFields(sub);
            }
        });
    }

    function fillSubscribeFields(sub) {
        
        $("#endpoint").val(sub.endpoint);
        $("#p256dh").val(arrayBufferToBase64(sub.getKey("p256dh")));
        $("#auth").val(arrayBufferToBase64(sub.getKey("auth")));
    }

    function arrayBufferToBase64(buffer) {
        var binary = '';
        var bytes = new Uint8Array(buffer);
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return window.btoa(binary);
    }

    function urlBase64ToUint8Array(base64String) {
        const padding = '='.repeat((4 - base64String.length % 4) % 4);
        const base64 = (base64String + padding)
            .replace(/-/g, '+')
            .replace(/_/g, '/');

        try {
            const rawData = window.atob(base64);
            return new Uint8Array([...rawData].map(char => char.charCodeAt(0)));
        } catch (e) {
            console.error('Erro ao converter chave Base64 para Uint8Array:', e.message);
            throw new Error('Chave VAPID inválida. Verifique se está no formato correto.');
        }
    }
</script>
</asp:Content>


<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <div id="GiveAccess" style="display:none;">
            Dê acesso para fazer notificações
        </div>
        <div id="NoSupport" style="display:none;">
            Seu navegador não suporta notificações push ou você bloqueou notificações
        </div>
        <h1>Teste de envio de notificações Push</h1>
        <div class="row">
            <div class="col col-md-12">
                <asp:Label ID="lbClient" runat="server" Text="Cliente"></asp:Label>
                <asp:TextBox ID="Client" runat="server"></asp:TextBox>
            </div>
        </div> 
        <div class="row">
            <div class="col col-md-12">
                <asp:Label ID="lbEndPoint" runat="server" Text="EndPoint:"></asp:Label>
                <asp:TextBox ID="endPoint" ClientIDMode="Static" runat="server"></asp:TextBox>
            </div>
        </div> 
        <div class="row">
            <div class="col col-md-12">
                <asp:Label ID="lb256dh" runat="server" Text="P256dh:"></asp:Label>
                <asp:TextBox ID="p256dh" ClientIDMode="Static" runat="server"></asp:TextBox>
            </div>
        </div> 
        <div class="row">
            <div class="col col-md-12">
                <asp:Label ID="lbAuth" runat="server" Text="Auth:"></asp:Label>
                <asp:TextBox ID="auth" ClientIDMode="Static" runat="server"></asp:TextBox>
            </div>
        </div> 
        <div class="row">
            <div class="col col-md-12">
                <asp:Button ID="btnTestar" runat="server" Text="Testar" />
            </div>
        </div>
    </main>

</asp:Content>
