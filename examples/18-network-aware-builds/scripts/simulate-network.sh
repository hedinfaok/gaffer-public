#!/bin/bash

# simulate-network.sh - Simulate various network conditions

cd "$(dirname "$0")/.."

profile=${1:-default}

echo "🌐 Network Simulation Tool"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case $profile in
    --profile)
        profile=$2
        ;;
esac

case $profile in
    satellite)
        echo "📡 Profile: Satellite Connection"
        echo "   Latency: 600ms"
        echo "   Bandwidth: 5 Mbps"
        echo "   Packet Loss: 2%"
        echo ""
        echo "This would simulate:"
        echo "   - Very high latency"
        echo "   - Low bandwidth"
        echo "   - Occasional packet loss"
        echo ""
        echo "Note: This is a simulation. In production, 'tc' (traffic control)"
        echo "      would be used to actually shape network traffic."
        ;;
        
    mobile)
        echo "📱 Profile: Mobile/4G Connection"
        echo "   Latency: 100-200ms (variable)"
        echo "   Bandwidth: 10-20 Mbps (variable)"
        echo "   Packet Loss: 0.5%"
        echo ""
        echo "This would simulate:"
        echo "   - Variable latency"
        echo "   - Variable bandwidth"
        echo "   - Occasional drops"
        ;;
        
    datacenter)
        echo "🏢 Profile: Data Center Connection"
        echo "   Latency: 1-5ms"
        echo "   Bandwidth: 1000 Mbps"
        echo "   Packet Loss: 0%"
        echo ""
        echo "This would simulate:"
        echo "   - Very low latency"
        echo "   - Very high bandwidth"
        echo "   - No packet loss"
        ;;
        
    --reset)
        echo "🔄 Resetting to default network conditions"
        echo ""
        echo "Network simulation reset to defaults:"
        echo "   US-East:      50ms latency, 100 Mbps"
        echo "   US-West:      100ms latency, 50 Mbps"
        echo "   EU-Central:   150ms latency, 25 Mbps"
        ;;
        
    *)
        echo "📊 Default Network Conditions (Current)"
        echo ""
        echo "Region Profiles:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  US-East (Primary):"
        echo "    - Latency: 50ms"
        echo "    - Bandwidth: 100 Mbps"
        echo "    - Simulates: Same-region cache access"
        echo ""
        echo "  US-West (Secondary):"
        echo "    - Latency: 100ms"
        echo "    - Bandwidth: 50 Mbps"
        echo "    - Simulates: Cross-coast access"
        echo ""
        echo "  EU-Central (Tertiary):"
        echo "    - Latency: 150ms"
        echo "    - Bandwidth: 25 Mbps"
        echo "    - Simulates: Trans-Atlantic access"
        echo ""
        echo "Available Profiles:"
        echo "  ./scripts/simulate-network.sh --profile satellite"
        echo "  ./scripts/simulate-network.sh --profile mobile"
        echo "  ./scripts/simulate-network.sh --profile datacenter"
        echo "  ./scripts/simulate-network.sh --reset"
        ;;
esac

echo ""
echo "💡 Note: Network simulation is currently illustrative."
echo "   In production environments, use 'tc' (traffic control) or"
echo "   Docker network plugins for actual traffic shaping."
echo ""
