#!/bin/bash
#2023.05.25 XI'AN
# This option could be documented a bit better and maybe even be simplified	
			mkdir -p /etc/openvpn/client/
			client_number=1
			dir_num=0
			number_of_clients2=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep -c "^V")
			if [[ "$number_of_clients2" = 0 ]]; then
				echo
				echo "没有可用的客户端，需要先生成openvpn的客户端文件。"
				exit
			fi
			dir_num=$(tail -n +1 /etc/openvpn/server/server.conf|grep -c "client-config-dir /etc/openvpn/client")
			if [[ "$dir_num" = 0 ]]; then
				echo "client-config-dir /etc/openvpn/client" >> /etc/openvpn/server/server.conf
				echo "server配置信息写入成功！"
			else
				echo "server配置信息已经存在，不需要重复写入！"
			fi
			server_ipa=$(tail -n +1 /etc/openvpn/server/server.conf | grep "255" | cut -d ' ' -f 2 | cut -d '.' -f 1)
			server_ipb=$(tail -n +1 /etc/openvpn/server/server.conf | grep "255" | cut -d ' ' -f 2 | cut -d '.' -f 2)
			server_ipc=$(tail -n +1 /etc/openvpn/server/server.conf | grep "255" | cut -d ' ' -f 2 | cut -d '.' -f 3)
			while (( "$client_number" <= "$number_of_clients2" )); do
				client=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$client_number"p)
				echo
				client_number=`expr $client_number + 1`
				echo "ifconfig-push "$server_ipa"."$server_ipb"."$server_ipc"."$client_number" 255.255.255.0" > /etc/openvpn/client/$client
				echo $client.ovpn的ip固定为："$server_ipa"."$server_ipb"."$server_ipc"."$client_number"
			done
			exit